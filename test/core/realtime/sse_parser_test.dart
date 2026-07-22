import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_app/core/realtime/sse_client.dart';

/// Mirrors the exact parsing logic of [SseClient._processLine] for testing.
class _SimSseClient {
  final StreamController<SseEvent> _controller =
      StreamController<SseEvent>.broadcast();
  Stream<SseEvent> get stream => _controller.stream;

  String _lineBuffer = '';
  String _dataBuffer = '';
  String? _eventType;
  String? _lastEventId;

  void emit(String data) {
    _lineBuffer += data;
    while (true) {
      final idx = _lineBuffer.indexOf('\n');
      if (idx == -1) break;
      final rawLine = _lineBuffer.substring(0, idx);
      _lineBuffer = _lineBuffer.substring(idx + 1);
      final line = rawLine.endsWith('\r')
          ? rawLine.substring(0, rawLine.length - 1)
          : rawLine;
      _processLine(line);
    }
  }

  void _processLine(String line) {
    if (line.isEmpty) {
      if (_dataBuffer.isNotEmpty) {
        _controller.add(SseEvent(
          id: _lastEventId,
          event: _eventType,
          data: _dataBuffer,
        ));
      }
      _dataBuffer = '';
      _eventType = null;
      return;
    }
    if (line.startsWith(':')) return;
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
    }
  }

  void close() => _controller.close();
}

void main() {
  group('SSE line parser', () {
    late _SimSseClient client;

    setUp(() {
      client = _SimSseClient();
    });

    tearDown(() {
      client.close();
    });

    test('parses a single data event', () async {
      final events = <SseEvent>[];
      final sub = client.stream.listen(events.add);

      client.emit('data: {"title":"hello"}\n\n');

      await Future.delayed(Duration.zero);

      expect(events.length, 1);
      expect(events.first.data, '{"title":"hello"}');
      expect(events.first.json?['title'], 'hello');

      await sub.cancel();
    });

    test('ignores heartbeat comments', () async {
      final events = <SseEvent>[];
      final sub = client.stream.listen(events.add);

      client.emit(': heartbeat\n\n');
      client.emit('data: {"title":"real"}\n\n');

      await Future.delayed(Duration.zero);

      expect(events.length, 1);
      expect(events.first.json?['title'], 'real');

      await sub.cancel();
    });

    test('joins multiple data lines with newline', () async {
      final events = <SseEvent>[];
      final sub = client.stream.listen(events.add);

      client.emit('data: line1\ndata: line2\ndata: line3\n\n');

      await Future.delayed(Duration.zero);

      expect(events.length, 1);
      expect(events.first.data, 'line1\nline2\nline3');

      await sub.cancel();
    });

    test('parses event type', () async {
      final events = <SseEvent>[];
      final sub = client.stream.listen(events.add);

      client.emit('event: notification\ndata: {"title":"test"}\n\n');

      await Future.delayed(Duration.zero);

      expect(events.length, 1);
      expect(events.first.event, 'notification');

      await sub.cancel();
    });

    test('parses id field', () async {
      final events = <SseEvent>[];
      final sub = client.stream.listen(events.add);

      client.emit('id: 42\ndata: {}\n\n');

      await Future.delayed(Duration.zero);

      expect(events.length, 1);
      expect(events.first.id, '42');

      await sub.cancel();
    });

    test('handles partial chunks (bytes arriving in pieces)', () async {
      final events = <SseEvent>[];
      final sub = client.stream.listen(events.add);

      client.emit('data: {"part');
      client.emit('ial":true}\n\n');

      await Future.delayed(Duration.zero);

      expect(events.length, 1);
      expect(events.first.json?['partial'], true);

      await sub.cancel();
    });

    test('handles CRLF line endings', () async {
      final events = <SseEvent>[];
      final sub = client.stream.listen(events.add);

      client.emit('data: {"ok":1}\r\n\r\n');

      await Future.delayed(Duration.zero);

      expect(events.length, 1);
      expect(events.first.json?['ok'], 1);

      await sub.cancel();
    });

    test('dispatches multiple events in sequence', () async {
      final events = <SseEvent>[];
      final sub = client.stream.listen(events.add);

      client.emit('data: 1\n\ndata: 2\n\ndata: 3\n\n');

      await Future.delayed(Duration.zero);

      expect(events.length, 3);
      expect(events[0].data, '1');
      expect(events[1].data, '2');
      expect(events[2].data, '3');

      await sub.cancel();
    });

    test('empty data line does not dispatch event', () async {
      final events = <SseEvent>[];
      final sub = client.stream.listen(events.add);

      client.emit('\n');

      await Future.delayed(Duration.zero);

      expect(events.length, 0);

      await sub.cancel();
    });

    test('parses notification payload matching API contract', () async {
      final events = <SseEvent>[];
      final sub = client.stream.listen(events.add);

      final payload = {
        "id": "abc-123",
        "userId": "user-456",
        "type": "info",
        "title": "Document approved",
        "message": "Your document has been validated.",
        "createdAt": "2026-07-12T18:58:59.5286771Z",
        "metadata": {"documentId": "doc-789"},
      };

      client.emit('data: ${jsonEncode(payload)}\n\n');

      await Future.delayed(Duration.zero);

      expect(events.length, 1);
      final json = events.first.json;
      expect(json?['id'], 'abc-123');
      expect(json?['userId'], 'user-456');
      expect(json?['title'], 'Document approved');
      expect(json?['message'], 'Your document has been validated.');
      expect(json?['createdAt'], '2026-07-12T18:58:59.5286771Z');
      expect(json?['metadata']?['documentId'], 'doc-789');

      await sub.cancel();
    });
  });
}
