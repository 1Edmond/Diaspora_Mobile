import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/entities/message.dart';
import '../../../../core/constants/enums.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';

class MessageBubble extends ConsumerWidget {
  final Message message;
  final bool showSender;
  final bool showTime;

  const MessageBubble({super.key, required this.message, this.showSender = true, this.showTime = true});

  String _formatTime(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Icon _statusIcon(MessageStatus status, BuildContext context) {
    switch (status) {
      case MessageStatus.SENDING:
        return Icon(Icons.access_time_rounded, size: 14, color: AppColors.getTextSecondary(context));
      case MessageStatus.SENT:
        return Icon(Icons.check_rounded, size: 14, color: AppColors.getTextSecondary(context));
      case MessageStatus.DELIVERED:
        return Icon(Icons.done_all_rounded, size: 14, color: AppColors.getTextSecondary(context));
      case MessageStatus.READ:
        return Icon(Icons.done_all_rounded, size: 14, color: AppColors.primary);
      case MessageStatus.FAILED:
        return const Icon(Icons.error_outline_rounded, size: 14, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final currentUserId = auth.value?.internalProfile.id ?? 'user_1';
    final isMe = message.senderId == currentUserId;

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 72 : 16,
        right: isMe ? 16 : 72,
        top: 3,
        bottom: 3,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe && showSender && message.senderName != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 3),
              child: Text(
                message.senderName!,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.getTextSecondary(context).withValues(alpha: 0.08),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
              ),
            ),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    color: AppColors.getTextMain(context),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.getTextSecondary(context),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      _statusIcon(message.status, context),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut);
  }
}
