import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../controllers/chat_notifier.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../../../../core/constants/enums.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(chatNotifierProvider.notifier)
          .selectConversation(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          Column(
            children: [
              _buildAppBar(chatState),
              Expanded(
                child: chatState.when(
                  data:
                      (state) => ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message =
                              state.messages[state.messages.length - 1 - index];
                          return MessageBubble(
                            message: message,
                            onPlayAudio: (url) {}, // mock
                          );
                        },
                      ),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, stack) => Center(child: Text('Erreur: $error')),
                ),
              ),
              MessageInput(
                onSendMessage: _sendMessage,
                onSendVoiceMessage: (p, d) {}, // mock
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      bottom: -100,
      right: -100,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondary.withValues(alpha: 0.03),
        ),
      ),
    );
  }

  Widget _buildAppBar(AsyncValue chatState) {
    return GlassContainer(
      borderRadius: 0,
      padding: const EdgeInsets.fromLTRB(8, 48, 16, 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textMain,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          chatState.maybeWhen(
            data: (state) {
              final conversation =
                  state.conversations
                      .where((c) => c.id == widget.conversationId)
                      .firstOrNull;
              return Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(conversation?.title[0].toUpperCase() ?? 'C'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation?.title ?? 'Chat',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textMain,
                          ),
                        ),
                        const Text(
                          'En ligne',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            orElse:
                () => const Expanded(
                  child: Text(
                    'Chat',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _sendMessage(
    String content,
    MessageType type, {
    String? mediaUrl,
    int? duration,
  }) {
    ref
        .read(chatNotifierProvider.notifier)
        .sendMessage(
          widget.conversationId,
          content,
          type,
          mediaUrl: mediaUrl,
          duration: duration,
        );
  }
}
