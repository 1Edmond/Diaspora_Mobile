import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/entities/conversation.dart';
import '../controllers/chat_notifier.dart';

class ChatListItem extends ConsumerWidget {
  final Conversation conversation;
  final VoidCallback? onTap;

  const ChatListItem({
    super.key,
    required this.conversation,
    this.onTap,
  });

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return DateFormat('EEE', 'fr').format(time);
    } else {
      return DateFormat('dd/MM/yy').format(time);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conv = conversation;

    return Dismissible(
      key: ValueKey(conv.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        final notifier = ref.read(chatNotifierProvider.notifier);
        if (direction == DismissDirection.startToEnd) {
          notifier.togglePinned(conv.id);
        } else {
          notifier.toggleMuted(conv.id);
        }
        return false; // never actually remove the tile from a swipe alone
      },
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: Colors.blue,
        icon: conv.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
        label: conv.isPinned ? 'Désépingler' : 'Épingler',
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: Colors.orange,
        icon: conv.isMuted ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
        label: conv.isMuted ? 'Réactiver' : 'Muet',
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showQuickActions(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: conv.isPinned
              ? (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02))
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildAvatar(conv, isDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conv.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.getTextMain(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conv.isPinned)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(Icons.push_pin_rounded,
                                  size: 14, color: AppColors.getTextSecondary(context)),
                            ),
                          if (conv.isMuted)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(Icons.notifications_off_rounded,
                                  size: 14, color: AppColors.getTextSecondary(context)),
                            ),
                          Text(
                            _formatTime(conv.lastMessageTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: conv.unreadCount > 0
                                  ? AppColors.primary
                                  : AppColors.getTextSecondary(context),
                              fontWeight: conv.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conv.lastMessage,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.getTextSecondary(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conv.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: conv.isMuted
                                    ? AppColors.getTextSecondary(context)
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                conv.unreadCount > 99
                                    ? '99+'
                                    : '${conv.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifier = ref.read(chatNotifierProvider.notifier);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2A3A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(conversation.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded),
              title: Text(conversation.isPinned ? 'Désépingler' : 'Épingler'),
              onTap: () {
                notifier.togglePinned(conversation.id);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: Icon(conversation.isMuted
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded),
              title: Text(conversation.isMuted ? 'Réactiver les notifications' : 'Mettre en sourdine'),
              onTap: () {
                notifier.toggleMuted(conversation.id);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text('Supprimer la conversation', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                notifier.deleteConversationLocally(conversation.id);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Conversation conv, bool isDark) {
    final color = conv.avatarColor ?? AppColors.primary;

    return Stack(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF1E2A3A) : color.withValues(alpha: 0.1),
          ),
          child: conv.avatarUrl != null && conv.avatarUrl!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    conv.avatarUrl!,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFallback(conv, color),
                  ),
                )
              : _buildFallback(conv, color),
        ),
        if (conv.isOnline)
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF1E2A3A) : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallback(Conversation conv, Color color) {
    final initial =
        conv.title.isNotEmpty ? conv.title[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }
}
