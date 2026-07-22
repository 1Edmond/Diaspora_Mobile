import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/realtime/sse_reconnect_service.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/notification.dart';
import 'notifications_providers.dart';

/// Reads the access token from Hive storage.
final accessTokenProvider = Provider<String?>((ref) {
  final storage = GetIt.instance<StorageService>();
  return storage.get<String>('accessToken');
});

/// Dio instance dedicated to SSE streaming (long receive timeout, no mock interceptor).
final _sseDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppConfig.realApiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      validateStatus: (_) => true,
      headers: {
        'Content-Type': 'application/json',
        'x-client-key': AppConfig.clientKey,
      },
    ),
  );
});

/// SSE endpoint URL (relative to baseUrl).
const _ssePath = '/notifications/stream';

/// Manages the [SseReconnectService] lifecycle tied to auth state.
/// When the user logs in, the stream starts.
/// When the user logs out, the stream stops.
final sseConnectionProvider = StateNotifierProvider<
    SseConnectionNotifier,
    SseConnectionState
  >((ref) {
    return SseConnectionNotifier(ref);
  });

class SseConnectionNotifier extends StateNotifier<SseConnectionState> {
  final Ref _ref;
  SseReconnectService? _service;

  SseConnectionNotifier(this._ref) : super(SseConnectionState.disconnected) {
    // Listen to auth state changes
    _ref.listen<AsyncValue<User?>>(
      authNotifierProvider,
      (prev, next) {
        next.whenData((user) {
          if (user != null) {
            // Logged in → start SSE
            start();
          } else {
            // Logged out → stop SSE
            stop();
          }
        });
      },
    );
  }

  void start() {
    final token = _ref.read(accessTokenProvider);
    if (token == null) {
      debugPrint('SSE: no access token — not starting');
      return;
    }
    _service?.dispose();

    final dio = _ref.read(_sseDioProvider);

    _service = SseReconnectService(
      dio: dio,
      url: _ssePath,
      accessToken: token,
      onEvent: (event) {
        final json = event.json;
        if (json != null) {
          final entity = _mapSseToEntity(json);
          _ref
              .read(notificationsStateProvider.notifier)
              .addNotificationFromSse(entity);
        }
      },
      onConnectionStateChanged: (s) {
        state = s;
      },
      onError: (e) {
        debugPrint('SSE error: $e');
      },
    );
    _service!.start();
    state = SseConnectionState.connecting;
  }

  void stop() {
    _service?.dispose();
    _service = null;
    state = SseConnectionState.disconnected;
  }

  void pause() {
    _service?.pause();
  }

  void resume() {
    _service?.resume();
  }

  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }

  NotificationEntity _mapSseToEntity(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['message'] as String? ?? '',
      timestamp:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      isRead: false,
      target: json['userId'] as String? ?? '',
      data: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
