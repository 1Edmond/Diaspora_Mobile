import 'dart:ui';
import '../../../../core/constants/enums.dart';
import '../../domain/entities/conversation.dart';

const _avatarColors = [
  Color(0xFF0033A0),
  Color(0xFFE91E63),
  Color(0xFF4CAF50),
  Color(0xFFFF9800),
  Color(0xFF9C27B0),
  Color(0xFF00BCD4),
  Color(0xFFF44336),
  Color(0xFF3F51B5),
];

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
    super.isOnline,
    super.category,
    super.avatarColor,
    super.groupMembers,
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

    final title = json['title'] as String? ?? 'Unknown';
    final colorIndex = title.hashCode.abs() % _avatarColors.length;

    return ConversationModel(
      id: json['id'] as String,
      type: type,
      title: title,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: json['unreadCount'] as int? ?? 0,
      participants: List<String>.from(json['participants'] ?? []),
      avatarUrl: json['avatarUrl'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      category: json['category'] as String?,
      avatarColor: _avatarColors[colorIndex],
      groupMembers: (json['groupMembers'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
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
    'isOnline': isOnline,
    'category': category,
    'groupMembers': groupMembers,
  };
}
