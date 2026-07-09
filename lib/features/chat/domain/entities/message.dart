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
    this.senderName,
  });
}
