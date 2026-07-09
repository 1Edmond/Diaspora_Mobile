import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../domain/entities/conversation.dart';
import '../controllers/chat_notifier.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: chatState.when(
              data:
                  (state) => CustomScrollView(
                    slivers: [
                      _buildAppBar(context),
                      if (state.conversations.isEmpty)
                        const SliverFillRemaining(
                          child: Center(child: Text('Aucune conversation')),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final conversation = state.conversations[index];
                              return _buildConversationItem(
                                conversation,
                                index,
                                context,
                              );
                            }, childCount: state.conversations.length),
                          ),
                        ),
                    ],
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildError(error),
            ),
          ),
        ],
      ),
      floatingActionButton: NeumorphicContainer(
        width: 60,
        height: 60,
        borderRadius: 30,
        color: AppColors.primary,
        child: IconButton(
          icon: const Icon(
            Icons.edit_note_rounded,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => context.push('/chat/create'),
        ),
      ).animate().scale(delay: 500.ms),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: -100,
      left: -50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.05),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Messages',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.getTextMain(context),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search_rounded, color: AppColors.getTextMain(context)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildConversationItem(Conversation conversation, int index, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(4),
        borderRadius: 24,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              backgroundImage:
                  conversation.avatarUrl != null
                      ? NetworkImage(conversation.avatarUrl!)
                      : null,
              child:
                  conversation.avatarUrl == null
                      ? Text(conversation.title[0].toUpperCase())
                      : null,
            ),
          ),
          title: Text(
            conversation.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.getTextMain(context),
            ),
          ),
          subtitle: Text(
            conversation.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.getTextSecondary(context)),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(conversation.lastMessageTime),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
              const SizedBox(height: 8),
              if (conversation.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    conversation.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () => context.go('/chat/${conversation.id}'),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1);
  }

  Widget _buildError(dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Erreur: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                () =>
                    ref.read(chatNotifierProvider.notifier).loadConversations(),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays > 0) return '${time.day}/${time.month}';
    if (difference.inHours > 0)
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    if (difference.inMinutes > 0) return '${difference.inMinutes}min';
    return 'maintenant';
  }
}
