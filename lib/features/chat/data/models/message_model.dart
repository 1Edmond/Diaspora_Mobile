import '../../../../core/constants/enums.dart';
import '../../domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.type,
    required super.content,
    required super.timestamp,
    required super.status,
    super.mentions,
    super.reactions,
    super.isTagged,
    super.mediaUrl,
    super.duration,
    super.senderName,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String? ?? 'text';
    MessageType type;
    switch (typeString) {
      case 'text': type = MessageType.TEXT; break;
      case 'voice': type = MessageType.AUDIO; break; // Map 'voice' to AUDIO
      case 'image': type = MessageType.IMAGE; break;
      case 'video': type = MessageType.VIDEO; break;
      case 'location': type = MessageType.LOCATION; break;
      case 'document': type = MessageType.DOCUMENT; break;
      default: type = MessageType.TEXT;
    }

    final statusString = json['status'] as String? ?? 'SENT';
    MessageStatus status;
    switch (statusString) {
      case 'SENDING': status = MessageStatus.SENDING; break;
      case 'SENT': status = MessageStatus.SENT; break;
      case 'DELIVERED': status = MessageStatus.DELIVERED; break;
      case 'READ': status = MessageStatus.READ; break;
      case 'FAILED': status = MessageStatus.FAILED; break;
      default: status = MessageStatus.SENT;
    }

    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      type: type,
      content: json['content'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: status,
      mentions: (json['mentions'] as List?)?.map((e) => e.toString()).toList() ?? [],
      reactions: (json['reactions'] as Map?)?.cast<String, String>() ?? {},
      isTagged: json['isTagged'] as bool? ?? false,
      mediaUrl: json['mediaUrl'] as String?,
      duration: json['duration'] as int?,
      senderName: json['senderName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'type': type.toString().split('.').last, // e.g. 'TEXT'
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
      'mentions': mentions,
      'reactions': reactions,
      'isTagged': isTagged,
      'mediaUrl': mediaUrl,
      'duration': duration,
      'senderName': senderName,
    };
  }
}
