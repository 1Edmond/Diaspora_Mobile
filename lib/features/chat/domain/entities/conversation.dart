import 'package:diaspora_app/core/constants/enums.dart';

class Conversation {
  final String id;
  final ConversationType type;
  final String title;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final List<String> participants;
  final String? avatarUrl;

  Conversation({
    required this.id,
    required this.type,
    required this.title,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.participants,
    this.avatarUrl,
  });

  Conversation copyWith({
    String? id,
    ConversationType? type,
    String? title,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    List<String>? participants,
    String? avatarUrl,
  }) {
    return Conversation(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      participants: participants ?? this.participants,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
