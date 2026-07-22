import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'sse_client.dart';

/// Wraps [SseClient] with automatic reconnection using exponential backoff.
///
/// - Initial delay: 2s, doubles up to 30s.
/// - Reset backoff after [stableThreshold] of stable connection.
/// - Stops on HTTP 401 (token invalid/expired) — auth layer handles refresh/logout.
/// - [onEvent] is called for every parsed SSE event.
/// - [onConnectionStateChanged] notifies the UI (connecting / connected / disconnected).
class SseReconnectService {
  final Dio _dio;
  final String _url;
  final String _accessToken;

  final Duration initialDelay;
  final Duration maxDelay;
  final Duration stableThreshold;

  SseClient? _currentClient;
  StreamSubscription<SseEvent>? _eventSub;
  Timer? _reconnectTimer;
  Timer? _stableTimer;
  bool _disposed = false;
  bool _paused = false;
  int _attempt = 0;

  final void Function(SseEvent event)? onEvent;
  final void Function(SseConnectionState state)? onConnectionStateChanged;
  final void Function(Object error)? onError;

  SseReconnectService({
    required Dio dio,
    required String url,
    required String accessToken,
    this.initialDelay = const Duration(seconds: 2),
    this.maxDelay = const Duration(seconds: 30),
    this.stableThreshold = const Duration(seconds: 30),
    this.onEvent,
    this.onConnectionStateChanged,
    this.onError,
  }) : _dio = dio,
       _url = url,
       _accessToken = accessToken;

  /// Starts the connection. Safe to call multiple times — if already connected, does nothing.
  void start() {
    if (_disposed || _paused) return;
    if (_currentClient != null) return;
    _connect();
  }

  /// Pauses reconnection (e.g. app goes to background). Closes current SSE connection.
  void pause() {
    _paused = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _stableTimer?.cancel();
    _stableTimer = null;
    _closeCurrent();
    onConnectionStateChanged?.call(SseConnectionState.disconnected);
  }

  /// Resumes after a [pause]. Resets backoff and reconnects immediately.
  void resume() {
    _paused = false;
    _attempt = 0;
    start();
  }

  void _connect() {
    if (_disposed || _paused) return;

    onConnectionStateChanged?.call(SseConnectionState.connecting);

    final client = SseClient(dio: _dio, url: _url, accessToken: _accessToken);
    _currentClient = client;

    final stream = client.connect();
    _eventSub = stream.listen(
      (event) {
        // Connection is stable — reset backoff
        _stableTimer?.cancel();
        _stableTimer = Timer(stableThreshold, () {
          _attempt = 0;
        });
        onEvent?.call(event);
      },
      onError: (Object e, StackTrace st) {
        debugPrint('SSE error: $e');
        onError?.call(e);
        _handleDisconnect(e);
      },
      onDone: () {
        debugPrint('SSE stream done');
        _handleDisconnect(null);
      },
    );
  }

  void _handleDisconnect(Object? error) {
    _closeCurrent();

    // Stop on 401 — token invalid, let auth layer handle it
    if (error is SseException && error.message.contains('401')) {
      debugPrint('SSE: 401 received — stopping reconnection');
      onConnectionStateChanged?.call(SseConnectionState.unauthorized);
      return;
    }

    if (_disposed || _paused) return;

    _attempt++;
    final delay = _computeDelay(_attempt);

    onConnectionStateChanged?.call(SseConnectionState.disconnected);

    debugPrint('SSE: reconnecting in ${delay.inSeconds}s (attempt $_attempt)');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _connect);
  }

  void _closeCurrent() {
    _eventSub?.cancel();
    _eventSub = null;
    _currentClient?.dispose();
    _currentClient = null;
  }

  Duration _computeDelay(int attempt) {
    // Exponential backoff: 2s, 4s, 8s, 16s, 30s, 30s, ...
    final seconds = initialDelay.inSeconds * (1 << (attempt - 1));
    final clamped = seconds > maxDelay.inSeconds ? maxDelay.inSeconds : seconds;
    return Duration(seconds: clamped);
  }

  /// Updates the access token and reconnects if the connection is active.
  void updateToken(String newToken) {
    final needsReconnect = _currentClient != null;
    _closeCurrent();
    // Recreate with new token — we need to rebuild the service with new credentials
    // The simplest approach: dispose and restart from the caller
    if (needsReconnect && !_disposed && !_paused) {
      _reconnectTimer?.cancel();
      _attempt = 0;
      _connectWithNewToken(newToken);
    }
  }

  void _connectWithNewToken(String newToken) {
    onConnectionStateChanged?.call(SseConnectionState.connecting);

    final client = SseClient(dio: _dio, url: _url, accessToken: newToken);
    _currentClient = client;

    final stream = client.connect();
    _eventSub = stream.listen(
      (event) {
        _stableTimer?.cancel();
        _stableTimer = Timer(stableThreshold, () {
          _attempt = 0;
        });
        onEvent?.call(event);
      },
      onError: (Object e, StackTrace st) {
        debugPrint('SSE error (post-token-update): $e');
        onError?.call(e);
        _handleDisconnect(e);
      },
      onDone: () {
        debugPrint('SSE stream done (post-token-update)');
        _handleDisconnect(null);
      },
    );
  }

  /// Permanently stops the service and releases all resources.
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _stableTimer?.cancel();
    _closeCurrent();
  }
}

enum SseConnectionState {
  connecting,
  connected,
  disconnected,
  unauthorized,
}
