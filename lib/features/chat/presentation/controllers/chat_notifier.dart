import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../../core/constants/enums.dart'; // Added for MessageType
import '../../../../core/di/injection.dart';
import '../../../../core/realtime/mock_realtime_service.dart';
import 'dart:async';

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<ChatState>>((ref) {
      return ChatNotifier(
        getIt<IChatRepository>(),
        getIt<MockRealtimeService>(),
      );
    });

class ChatState {
  final List<Conversation> conversations;
  final List<Message> messages;
  final String? selectedConversationId;

  const ChatState({
    this.conversations = const [],
    this.messages = const [],
    this.selectedConversationId,
  });

  ChatState copyWith({
    List<Conversation>? conversations,
    List<Message>? messages,
    String? selectedConversationId,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      selectedConversationId:
          selectedConversationId ?? this.selectedConversationId,
    );
  }
}

class ChatNotifier extends StateNotifier<AsyncValue<ChatState>> {
  final IChatRepository repository;
  final MockRealtimeService realtime;

  final Map<String, StreamSubscription<Message>> _messageSubscriptions = {};

  ChatNotifier(this.repository, this.realtime)
    : super(const AsyncValue.data(ChatState()));

  @override
  void dispose() {
    for (final s in _messageSubscriptions.values) {
      s.cancel();
    }
    _messageSubscriptions.clear();
    super.dispose();
  }

  void _ensureSubscribed(String conversationId) {
    if (_messageSubscriptions.containsKey(conversationId)) return;
    final sub = realtime.messagesFor(conversationId).listen((message) {
      // Handle incoming message
      final currentState = state.value ?? const ChatState();
      // If user is viewing this conversation, append to messages
      if (currentState.selectedConversationId == conversationId) {
        final updatedMessages = [...currentState.messages, message];
        state = AsyncValue.data(
          currentState.copyWith(messages: updatedMessages),
        );
      }
      // Update conversations list last message / unread count
      final updatedConversations =
          currentState.conversations.map((c) {
            if (c.id == conversationId) {
              return c.copyWith(
                lastMessage: message.content,
                lastMessageTime: message.timestamp,
                unreadCount: c.unreadCount + 1,
              );
            }
            return c;
          }).toList();
      state = AsyncValue.data(
        currentState.copyWith(conversations: updatedConversations),
      );
    });
    _messageSubscriptions[conversationId] = sub;
  }

  Future<void> loadConversations() async {
    state = const AsyncValue.loading();
    try {
      final conversations = await repository.getConversations();
      state = AsyncValue.data(ChatState(conversations: conversations));
      // Subscribe to realtime streams for each conversation (mock)
      for (final c in conversations) {
        _ensureSubscribed(c.id);
      }
    } catch (e, _) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> selectConversation(String conversationId) async {
    final currentState = state.value ?? const ChatState();
    state = AsyncValue.data(
      currentState.copyWith(selectedConversationId: conversationId),
    );

    // Load messages for the selected conversation
    await loadMessages(conversationId);
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      final messages = await repository.getMessages(conversationId);
      final currentState = state.value ?? const ChatState();
      state = AsyncValue.data(
        currentState.copyWith(
          messages: messages,
          selectedConversationId: conversationId,
        ),
      );
    } catch (e, _) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> sendMessage(
    String conversationId,
    String content,
    MessageType type, {
    String? mediaUrl,
    int? duration,
    String? replyToMessageId,
  }) async {
    try {
      final message = await repository.sendMessage(
        conversationId,
        content,
        type,
        mediaUrl: mediaUrl,
        duration: duration,
      );
      final withReply = replyToMessageId != null
          ? message.copyWith(replyToMessageId: replyToMessageId)
          : message;
      final currentState = state.value ?? const ChatState();
      final updatedMessages = [...currentState.messages, withReply];
      state = AsyncValue.data(currentState.copyWith(messages: updatedMessages));
      // Broadcast via mock realtime so other clients receive it
      realtime.emitMessage(conversationId, withReply);
    } catch (e, _) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Adds or removes [emoji] as the current user's reaction on a message.
  /// Purely local/optimistic for now: IChatRepository has no reaction
  /// endpoint, so this does not persist across sessions or sync to other
  /// participants yet — see the chat feature gap report for what a real
  /// backend contract for this would need.
  void toggleReaction(String messageId, String userId, String emoji) {
    final currentState = state.value;
    if (currentState == null) return;
    final updatedMessages = currentState.messages.map((m) {
      if (m.id != messageId) return m;
      final reactions = Map<String, String>.from(m.reactions);
      if (reactions[userId] == emoji) {
        reactions.remove(userId);
      } else {
        reactions[userId] = emoji;
      }
      return m.copyWith(reactions: reactions);
    }).toList();
    state = AsyncValue.data(currentState.copyWith(messages: updatedMessages));
  }

  /// Removes a message from local state only. IChatRepository has no
  /// delete endpoint yet, so this does not delete anything server-side —
  /// treat as "hide locally" until a real endpoint exists.
  void deleteMessageLocally(String messageId) {
    final currentState = state.value;
    if (currentState == null) return;
    final updatedMessages =
        currentState.messages.where((m) => m.id != messageId).toList();
    state = AsyncValue.data(currentState.copyWith(messages: updatedMessages));
  }

  void togglePinned(String conversationId) {
    final currentState = state.value;
    if (currentState == null) return;
    final updated = currentState.conversations.map((c) {
      if (c.id != conversationId) return c;
      return c.copyWith(isPinned: !c.isPinned);
    }).toList();
    state = AsyncValue.data(currentState.copyWith(conversations: updated));
  }

  void toggleMuted(String conversationId) {
    final currentState = state.value;
    if (currentState == null) return;
    final updated = currentState.conversations.map((c) {
      if (c.id != conversationId) return c;
      return c.copyWith(isMuted: !c.isMuted);
    }).toList();
    state = AsyncValue.data(currentState.copyWith(conversations: updated));
  }

  /// Removes a conversation from local state only — same caveat as
  /// deleteMessageLocally: no backend endpoint exists yet for this.
  void deleteConversationLocally(String conversationId) {
    final currentState = state.value;
    if (currentState == null) return;
    final updated =
        currentState.conversations.where((c) => c.id != conversationId).toList();
    state = AsyncValue.data(currentState.copyWith(conversations: updated));
  }

  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await repository.markMessagesAsRead(conversationId);
      // Update conversation unread count
      final currentState = state.value ?? const ChatState();
      final updatedConversations =
          currentState.conversations.map((conv) {
            if (conv.id == conversationId) {
              return conv.copyWith(unreadCount: 0);
            }
            return conv;
          }).toList();
      state = AsyncValue.data(
        currentState.copyWith(conversations: updatedConversations),
      );
    } catch (_) {
      // Ignore errors for marking as read
    }
  }

  Future<Conversation> createConversation(
    String title,
    List<String> participants,
  ) async {
    try {
      final conversation = await repository.createConversation(
        title,
        participants,
      );
      final currentState = state.value ?? const ChatState();
      final updatedConversations = [
        conversation,
        ...currentState.conversations,
      ];
      state = AsyncValue.data(
        currentState.copyWith(conversations: updatedConversations),
      );
      return conversation;
    } catch (e, _) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}
