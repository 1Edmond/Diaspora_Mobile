import 'dart:async';

import '../../features/chat/domain/entities/message.dart';

/// Simple mock realtime service used during development to emit events.
class MockRealtimeService {
  // Chat messages per conversation
  final Map<String, StreamController<Message>> _messageControllers = {};

  // Global notification stream (simple string payloads for now)
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController.broadcast();

  // Community events (new post or comment)
  final StreamController<Map<String, dynamic>> _communityController =
      StreamController.broadcast();

  // Committee events (proposal/vote updates)
  final StreamController<Map<String, dynamic>> _committeeController =
      StreamController.broadcast();

  Stream<Message> messagesFor(String conversationId) {
    return _messageControllers
        .putIfAbsent(
          conversationId,
          () => StreamController<Message>.broadcast(),
        )
        .stream;
  }

  void emitMessage(String conversationId, Message message) {
    final ctrl = _messageControllers.putIfAbsent(
      conversationId,
      () => StreamController<Message>.broadcast(),
    );
    if (!ctrl.isClosed) ctrl.add(message);
  }

  Stream<Map<String, dynamic>> get notifications =>
      _notificationController.stream;
  void emitNotification(Map<String, dynamic> payload) {
    if (!_notificationController.isClosed) _notificationController.add(payload);
  }

  Stream<Map<String, dynamic>> get communityEvents =>
      _communityController.stream;
  void emitCommunityEvent(Map<String, dynamic> payload) {
    if (!_communityController.isClosed) _communityController.add(payload);
  }

  Stream<Map<String, dynamic>> get committeeEvents =>
      _committeeController.stream;
  void emitCommitteeEvent(Map<String, dynamic> payload) {
    if (!_committeeController.isClosed) _committeeController.add(payload);
  }

  void dispose() {
    for (final c in _messageControllers.values) {
      c.close();
    }
    _notificationController.close();
    _communityController.close();
    _committeeController.close();
  }
}
