import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// A single SSE event parsed from the stream.
class SseEvent {
  final String? id;
  final String? event;
  final String data;

  const SseEvent({this.id, this.event, required this.data});

  Map<String, dynamic>? get json {
    if (data.isEmpty) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

/// Low-level SSE client that opens a streaming HTTP connection via Dio,
/// parses the SSE protocol line by line, and exposes a [Stream<SseEvent>].
///
/// Protocol rules implemented:
/// - Lines starting with `:` are comments (heartbeats) → ignored
/// - `data: <text>` accumulates data lines; multiple data lines are joined with `\n`
/// - `event: <type>` sets the event type for the next dispatch
/// - `id: <id>` sets the last event ID
/// - An empty line dispatches the accumulated event
class SseClient {
  final Dio _dio;
  final String _url;
  final String _accessToken;

  StreamController<SseEvent>? _controller;
  Response<ResponseBody>? _response;
  StreamSubscription<List<int>>? _byteSub;
  bool _disposed = false;

  SseClient({
    required Dio dio,
    required String url,
    required String accessToken,
  }) : _dio = dio,
       _url = url,
       _accessToken = accessToken;

  /// Opens the SSE connection and returns a [Stream<SseEvent>].
  /// Completes the stream when the connection closes or errors.
  Stream<SseEvent> connect() {
    _controller = StreamController<SseEvent>.broadcast(
      onCancel: _onCancel,
    );
    _doConnect();
    return _controller!.stream;
  }

  Future<void> _doConnect() async {
    if (_disposed) return;
    try {
      _response = await _dio.get<ResponseBody>(
        _url,
        queryParameters: {'access_token': _accessToken},
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      if (_response!.statusCode != 200) {
        _controller!.addError(
          SseException('HTTP ${_response!.statusCode}'),
          StackTrace.current,
        );
        await _controller!.close();
        return;
      }

      final byteStream = _response!.data!.stream;
      _byteSub = byteStream.listen(
        _onBytes,
        onError: (Object e, StackTrace st) {
          if (!_disposed && _controller != null && !_controller!.isClosed) {
            _controller!.addError(e, st);
          }
        },
        onDone: () {
          if (!_disposed && _controller != null && !_controller!.isClosed) {
            _controller!.close();
          }
        },
      );
    } catch (e, st) {
      if (!_disposed && _controller != null && !_controller!.isClosed) {
        _controller!.addError(e, st);
        _controller!.close();
      }
    }
  }

  void _onBytes(List<int> bytes) {
    _lineBuffer += utf8.decode(bytes);
    while (true) {
      final idx = _lineBuffer.indexOf('\n');
      if (idx == -1) break;
      final rawLine = _lineBuffer.substring(0, idx);
      _lineBuffer = _lineBuffer.substring(idx + 1);
      final line = rawLine.endsWith('\r') ? rawLine.substring(0, rawLine.length - 1) : rawLine;
      _processLine(line);
    }
  }

  // ── SSE parsing state ──
  String _lineBuffer = '';
  String _dataBuffer = '';
  String? _eventType;
  String? _lastEventId;

  void _processLine(String line) {
    // Empty line → dispatch event
    if (line.isEmpty) {
      if (_dataBuffer.isNotEmpty) {
        final event = SseEvent(
          id: _lastEventId,
          event: _eventType,
          data: _dataBuffer,
        );
        if (!_disposed && _controller != null && !_controller!.isClosed) {
          _controller!.add(event);
        }
      }
      _dataBuffer = '';
      _eventType = null;
      return;
    }

    // Comment / heartbeat → ignore
    if (line.startsWith(':')) return;

    // Field parsing
    final colonIdx = line.indexOf(':');
    String field;
    String value;
    if (colonIdx == -1) {
      field = line;
      value = '';
    } else {
      field = line.substring(0, colonIdx);
      value = line.substring(colonIdx + 1);
      if (value.startsWith(' ')) value = value.substring(1);
    }

    switch (field) {
      case 'data':
        _dataBuffer = _dataBuffer.isEmpty ? value : '$_dataBuffer\n$value';
        break;
      case 'event':
        _eventType = value;
        break;
      case 'id':
        _lastEventId = value;
        break;
      // 'retry' is ignored — we manage our own reconnection logic
    }
  }

  void _onCancel() {
    dispose();
  }

  /// Closes the SSE connection and releases resources.
  void dispose() {
    _disposed = true;
    _byteSub?.cancel();
    if (_controller != null && !_controller!.isClosed) {
      _controller!.close();
    }
    _controller = null;
  }
}

/// Exception thrown when the SSE connection fails.
class SseException implements Exception {
  final String message;
  SseException(this.message);
  @override
  String toString() => 'SseException: $message';
}
