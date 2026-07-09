import '../entities/conversation.dart';
import '../entities/message.dart';
import '../entities/group.dart';
import 'package:diaspora_app/core/constants/enums.dart';

abstract class IChatRepository {
  Future<List<Conversation>> getConversations();
  Future<List<Message>> getMessages(String conversationId);
  Future<Message> sendMessage(
    String conversationId,
    String content,
    MessageType type, {
    String? mediaUrl,
    int? duration,
  });
  Future<void> markMessagesAsRead(String conversationId);
  Future<Conversation> createConversation(
    String title,
    List<String> participants,
  );

  // V2 Additions
  Future<void> createGroup(Group group);
  Stream<Message> get messageStream;
}
