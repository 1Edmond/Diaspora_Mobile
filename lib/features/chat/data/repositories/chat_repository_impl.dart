import 'dart:async';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../../data/mock/mock_chat.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/network/dio_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements IChatRepository {
  final DioClient _client;
  final _messageController = StreamController<Message>.broadcast();

  ChatRepositoryImpl({required DioClient client}) : _client = client;

  @override
  Stream<Message> get messageStream => _messageController.stream;

  @override
  Future<List<Conversation>> getConversations() async {
    final res = await _client.get('/chat/conversations');
    if (res is List) {
      return res
          .map(
            (json) => ConversationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    }
    return [];
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    final res = await _client.get('/chat/messages/$conversationId');
    if (res is List) {
      return res
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<Message> sendMessage(
    String conversationId,
    String content,
    MessageType type, {
    String? mediaUrl,
    int? duration,
  }) async {
    // Placeholder message construction
    final msg = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: 'user_1',
      type: type,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.SENT,
      mentions: [],
      reactions: {},
      isTagged: false,
    );

    if (AppConfig.useMockData) {
      // Simulate delay
      await Future.delayed(const Duration(milliseconds: 200));
      _messageController.add(msg);
    }
    return msg;
  }

  @override
  Future<void> markMessagesAsRead(String conversationId) async {}

  @override
  Future<Conversation> createConversation(
    String title,
    List<String> participants,
  ) async {
    final res = await _client.post('/chat/conversations', data: {
      'title': title,
      'participants': participants,
    });
    return ConversationModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<String> resolveChatProfileByExternal(String externalProfileId) async {
    final res = await _client.get('/chat/profiles/by-external/$externalProfileId');
    final map = res as Map<String, dynamic>;
    return map['chatProfileId'] as String? ??
        map['ChatProfileId'] as String? ??
        'chatprofile_$externalProfileId';
  }

  @override
  Future<Conversation> createDirectConversation(
    String initiatorChatProfileId,
    String recipientChatProfileId,
  ) async {
    final res = await _client.post('/chat/conversations', data: {
      'initiatorChatProfileId': initiatorChatProfileId,
      'recipientChatProfileId': recipientChatProfileId,
    });
    return ConversationModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> createGroup(Group group) async {
    if (AppConfig.useMockData) {
      mockGroups.add(group);
    }
  }
}
