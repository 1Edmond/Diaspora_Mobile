import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/entities/conversation.dart';
import '../controllers/chat_notifier.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends ConsumerState<ConversationListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).loadConversations();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearch(context),
            Expanded(
              child: chatState.when(
                data: (state) {
                  final items = state.conversations.where((c) =>
                    _searchQuery.isEmpty ||
                    c.title.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.getTextSecondary(context)),
                          const SizedBox(height: 12),
                          Text('Aucune conversation', style: TextStyle(color: AppColors.getTextSecondary(context))),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(height: 1, indent: 88, color: AppColors.getTextSecondary(context).withValues(alpha: 0.08)),
                    itemBuilder: (context, index) {
                      final conversation = items[index];
                      return _ConversationTile(
                        conversation: conversation,
                        onTap: () => context.push('/chat/${conversation.id}'),
                      ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Erreur: $e'),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: () => ref.read(chatNotifierProvider.notifier).loadConversations(), child: const Text('Réessayer')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/chat/create'),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ).animate().scale(delay: 500.ms),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Text(
            'Messages',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.getTextMain(context)),
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.getTextSecondary(context).withValues(alpha: 0.1)),
            child: IconButton(
              icon: Icon(Icons.edit_note_rounded, size: 20, color: AppColors.getTextMain(context)),
              onPressed: () => context.push('/chat/create'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.getTextSecondary(context).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Rechercher',
            hintStyle: TextStyle(fontSize: 15, color: AppColors.getTextSecondary(context)),
            prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.getTextSecondary(context)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 6) return '${time.day}/${time.month}';
    if (diff.inDays > 0) {
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[time.weekday - 1];
    }
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _avatarColor(String name) {
    final colors = [AppColors.primary, AppColors.secondary, AppColors.accent, Colors.orange, Colors.purple, Colors.teal];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: _avatarColor(conversation.title),
                  backgroundImage: conversation.avatarUrl != null ? NetworkImage(conversation.avatarUrl!) : null,
                  child: conversation.avatarUrl == null
                      ? Text(conversation.title[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))
                      : null,
                ),
                if (conversation.unreadCount > 0)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          conversation.unreadCount > 99 ? '99+' : conversation.unreadCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.title,
                          style: TextStyle(
                            fontWeight: conversation.unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.getTextMain(context),
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(conversation.lastMessageTime),
                        style: TextStyle(fontSize: 12, color: AppColors.getTextSecondary(context)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (conversation.lastMessage.isNotEmpty && ['user_4', 'user_2', 'user_3', 'user_5'].contains(conversation.id == 'conv_1' ? 'user_1' : null)) ...[
                        Text('Vous: ', style: TextStyle(fontSize: 14, color: AppColors.getTextSecondary(context))),
                      ],
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: conversation.unreadCount > 0 ? AppColors.getTextMain(context) : AppColors.getTextSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
