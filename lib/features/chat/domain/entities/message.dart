import 'package:diaspora_app/core/constants/enums.dart';

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final MessageType type;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;
  final List<String> mentions;
  final Map<String, String> reactions; // userId -> reaction
  final bool isTagged;
  final String? mediaUrl;
  final int? duration;

  /// Id of the message this one replies to, if any. Client-side only for
  /// now — there is no backend field/endpoint for this yet (see
  /// ChatNotifier.replyToMessageId / MessageBubble's reply preview).
  final String? replyToMessageId;

  // Computed/Frontend helpers
  final String? senderName; // Optional, might be fetched separately

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.content,
    required this.timestamp,
    required this.status,
    this.mentions = const [],
    this.reactions = const {},
    this.isTagged = false,
    this.mediaUrl,
    this.duration,
    this.replyToMessageId,
    this.senderName,
  });

  Message copyWith({
    MessageStatus? status,
    Map<String, String>? reactions,
    String? replyToMessageId,
  }) {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      type: type,
      content: content,
      timestamp: timestamp,
      status: status ?? this.status,
      mentions: mentions,
      reactions: reactions ?? this.reactions,
      isTagged: isTagged,
      mediaUrl: mediaUrl,
      duration: duration,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      senderName: senderName,
    );
  }
}
