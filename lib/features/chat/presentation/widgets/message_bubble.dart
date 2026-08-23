import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/entities/message.dart';
import '../../../../core/constants/enums.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';

class MessageBubble extends ConsumerWidget {
  final Message message;
  final bool showSender;
  final bool showTime;
  final bool isGroupChat;

  const MessageBubble({
    super.key,
    required this.message,
    this.showSender = true,
    this.showTime = true,
    this.isGroupChat = false,
  });

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileProvider);
    final currentUserId = activeProfile?.id ?? 'user_1';
    final isMe = message.senderId == currentUserId ||
        message.senderId == 'user_1' ||
        message.senderId == 'current_user';

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 48 : 8,
        right: isMe ? 8 : 48,
        top: 2,
        bottom: 2,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isMe
                ? const Color(0xFF4CAF50)
                : Colors.white,
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
              if ((isGroupChat || (showSender && !isMe)) && message.senderName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    message.senderName!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.3,
                  color: isMe ? Colors.white : const Color(0xFF1E2A3A),
                ),
              ),
              const SizedBox(height: 2),
              Row(
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
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 150.ms);
  }
}
