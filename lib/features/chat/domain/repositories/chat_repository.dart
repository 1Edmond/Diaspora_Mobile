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

  /// Resolves a Chat profile id from an external (Freelance) profile id.
  Future<String> resolveChatProfileByExternal(String externalProfileId);

  /// Idempotent direct-message creation between two chat profile ids.
  Future<Conversation> createDirectConversation(
    String initiatorChatProfileId,
    String recipientChatProfileId,
  );

  // V2 Additions
  Future<void> createGroup(Group group);
  Stream<Message> get messageStream;
}
