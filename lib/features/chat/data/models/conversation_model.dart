import '../../../../core/constants/enums.dart';
import '../../domain/entities/conversation.dart';

class ConversationModel extends Conversation {
  ConversationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.lastMessage,
    required super.lastMessageTime,
    required super.unreadCount,
    required super.participants,
    super.avatarUrl,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String? ?? 'direct';
    ConversationType type;
    switch (typeString) {
      case 'group':
        type = ConversationType.GROUP;
        break;
      case 'city_group':
        type = ConversationType.CITY_GROUP;
        break;
      default:
        type = ConversationType.DIRECT;
    }

    return ConversationModel(
      id: json['id'] as String,
      type: type,
      title: json['title'] as String? ?? 'Unknown',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: json['unreadCount'] as int? ?? 0,
      participants: List<String>.from(json['participants'] ?? []),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString().split('.').last.toLowerCase(),
    'title': title,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime.toIso8601String(),
    'unreadCount': unreadCount,
    'participants': participants,
    'avatarUrl': avatarUrl,
  };
}
