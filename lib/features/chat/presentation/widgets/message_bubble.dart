import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/entities/message.dart';
import '../../../../core/constants/enums.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';
import '../controllers/chat_notifier.dart';
import 'voice_message_player.dart';

const _quickReactions = ['❤️', '👍', '😂', '😮', '😢', '🙏'];

class MessageBubble extends ConsumerStatefulWidget {
  final Message message;
  final bool showSender;
  final bool showTime;
  final bool isGroupChat;
  final Message? repliedMessage;
  final ValueChanged<Message>? onSwipeReply;

  const MessageBubble({
    super.key,
    required this.message,
    this.showSender = true,
    this.showTime = true,
    this.isGroupChat = false,
    this.repliedMessage,
    this.onSwipeReply,
  });

  @override
  ConsumerState<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<MessageBubble>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  static const _replyThreshold = 56.0;

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Widget _statusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.SENDING:
        return const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54),
        );
      case MessageStatus.SENT:
        return const Icon(Icons.check_rounded, size: 14, color: Colors.white54);
      case MessageStatus.DELIVERED:
        return const Icon(Icons.done_all_rounded, size: 14, color: Colors.white54);
      case MessageStatus.READ:
        return const Icon(Icons.done_all_rounded, size: 14, color: Color(0xFF90CAF9));
      case MessageStatus.FAILED:
        return const Icon(Icons.error_outline_rounded, size: 14, color: Colors.redAccent);
    }
  }

  void _showActionMenu(BuildContext context, bool isMe, String currentUserId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final emoji in _quickReactions)
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(chatNotifierProvider.notifier)
                            .toggleReaction(widget.message.id, currentUserId, emoji);
                        Navigator.of(ctx).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(emoji, style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: const Text('Répondre'),
              onTap: () {
                Navigator.of(ctx).pop();
                widget.onSwipeReply?.call(widget.message);
              },
            ),
            if (widget.message.type == MessageType.TEXT)
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Copier'),
                onTap: () => Navigator.of(ctx).pop(),
              ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                title: const Text('Supprimer', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  ref.read(chatNotifierProvider.notifier).deleteMessageLocally(widget.message.id);
                  Navigator.of(ctx).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isMe, BuildContext context) {
    switch (widget.message.type) {
      case MessageType.IMAGE:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: widget.message.mediaUrl != null
              ? Image.network(
                  widget.message.mediaUrl!,
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _mediaFallback(Icons.broken_image_outlined),
                )
              : _mediaFallback(Icons.image_outlined),
        );
      case MessageType.VIDEO:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 220, height: 220, color: Colors.black87),
              const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 48),
              if (widget.message.duration != null)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${widget.message.duration}s',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
        );
      case MessageType.AUDIO:
        return VoiceMessagePlayer(
          audioUrl: widget.message.mediaUrl ?? '',
          durationSeconds: widget.message.duration ?? 0,
          isMe: isMe,
        );
      case MessageType.DOCUMENT:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isMe ? Colors.white : AppColors.primary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.insert_drive_file_rounded,
                color: isMe ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                widget.message.content.isEmpty ? 'Document' : widget.message.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isMe ? Colors.white : const Color(0xFF1E2A3A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case MessageType.LOCATION:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 200,
            height: 120,
            color: (isMe ? Colors.white : AppColors.primary).withValues(alpha: 0.12),
            child: Icon(
              Icons.location_on_rounded,
              size: 36,
              color: isMe ? Colors.white : AppColors.primary,
            ),
          ),
        );
      case MessageType.TEXT:
        return Text(
          widget.message.content,
          style: TextStyle(
            fontSize: 15,
            height: 1.3,
            color: isMe ? Colors.white : (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1E2A3A)),
          ),
        );
    }
  }

  Widget _mediaFallback(IconData icon) => Container(
        width: 220,
        height: 220,
        color: Colors.black12,
        child: Icon(icon, size: 40, color: Colors.black38),
      );

  Widget _buildReplyPreview(bool isMe) {
    final replied = widget.repliedMessage;
    if (replied == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: (isMe ? Colors.white : AppColors.primary).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: isMe ? Colors.white : AppColors.primary, width: 3),
        ),
      ),
      child: Text(
        replied.type == MessageType.TEXT
            ? replied.content
            : '📎 ${replied.type.name}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: isMe ? Colors.white.withValues(alpha: 0.85) : AppColors.getTextSecondary(context),
        ),
      ),
    );
  }

  Widget _buildReactions() {
    if (widget.message.reactions.isEmpty) return const SizedBox.shrink();
    final counts = <String, int>{};
    for (final emoji in widget.message.reactions.values) {
      counts[emoji] = (counts[emoji] ?? 0) + 1;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: counts.entries
            .map((e) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${e.key} ${e.value > 1 ? e.value : ''}',
                      style: const TextStyle(fontSize: 12)),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileProvider);
    final currentUserId = activeProfile?.id ?? 'user_1';
    final message = widget.message;
    final isMe = message.senderId == currentUserId ||
        message.senderId == 'user_1' ||
        message.senderId == 'current_user';
    final isMedia = message.type != MessageType.TEXT && message.type != MessageType.DOCUMENT;

    return GestureDetector(
      onLongPress: () => _showActionMenu(context, isMe, currentUserId),
      onDoubleTap: () => ref
          .read(chatNotifierProvider.notifier)
          .toggleReaction(message.id, currentUserId, '❤️'),
      onHorizontalDragUpdate: (details) {
        // Swipe-to-reply, Telegram-style: drag right on any bubble.
        if (details.delta.dx > 0) {
          setState(() => _dragX = (_dragX + details.delta.dx).clamp(0, _replyThreshold + 20));
        }
      },
      onHorizontalDragEnd: (details) {
        if (_dragX >= _replyThreshold) widget.onSwipeReply?.call(message);
        setState(() => _dragX = 0);
      },
      child: Transform.translate(
        offset: Offset(_dragX, 0),
        child: Stack(
          children: [
            if (_dragX > 8)
              Positioned(
                left: -32,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Opacity(
                    opacity: (_dragX / _replyThreshold).clamp(0, 1),
                    child: const Icon(Icons.reply_rounded, size: 20, color: Colors.grey),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                left: isMe ? 48 : 8,
                right: isMe ? 8 : 48,
                top: 2,
                bottom: 2,
              ),
              child: Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: isMedia && message.type != MessageType.AUDIO
                      ? const EdgeInsets.all(4)
                      : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xFF4CAF50)
                        : (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF232E3C)
                            : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((widget.isGroupChat || (widget.showSender && !isMe)) &&
                          message.senderName != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3, left: 4, top: 2),
                          child: Text(
                            message.senderName!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      Padding(
                        padding: isMedia && message.type != MessageType.AUDIO
                            ? const EdgeInsets.all(2)
                            : EdgeInsets.zero,
                        child: _buildReplyPreview(isMe),
                      ),
                      Padding(
                        padding: isMedia && message.type != MessageType.AUDIO
                            ? const EdgeInsets.symmetric(horizontal: 2)
                            : EdgeInsets.zero,
                        child: _buildContent(isMe, context),
                      ),
                      _buildReactions(),
                      const SizedBox(height: 2),
                      Padding(
                        padding: isMedia && message.type != MessageType.AUDIO
                            ? const EdgeInsets.symmetric(horizontal: 4)
                            : EdgeInsets.zero,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: isMe
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : AppColors.getTextSecondary(context),
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              _statusIcon(message.status),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 150.ms);
  }
}
