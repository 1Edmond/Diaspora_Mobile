import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../domain/entities/message.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../../../core/constants/enums.dart';

class MessageBubble extends ConsumerStatefulWidget {
  final Message message;
  final Function(String) onPlayAudio;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onPlayAudio,
  });

  @override
  ConsumerState<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final currentUserId = auth.value?.internalProfile.id ?? 'user_1';
    final isMe = widget.message.senderId == currentUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Text(
                widget.message.senderName ?? 'Inconnu',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

          isMe ? _buildMeMessage() : _buildOtherMessage(),

          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              _formatTime(widget.message.timestamp),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(
      begin: const Offset(0.8, 0.8),
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildMeMessage() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildContent(true),
    );
  }

  Widget _buildOtherMessage() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      opacity: 0.8,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        child: _buildContent(false),
      ),
    );
  }

  Widget _buildContent(bool isMe) {
    switch (widget.message.type) {
      case MessageType.TEXT:
        return Text(
          widget.message.content,
          style: TextStyle(
            color: isMe ? Colors.white : AppColors.textMain,
            fontSize: 15,
            height: 1.4,
          ),
        );
      case MessageType.AUDIO:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_fill_rounded,
              color: isMe ? Colors.white : AppColors.primary,
              size: 32,
            ),
            const SizedBox(width: 8),
            Container(
              width: 100,
              height: 4,
              decoration: BoxDecoration(
                color: (isMe ? Colors.white : AppColors.primary).withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );
      default:
        return const Text('Format non supporté');
    }
  }

  String _formatTime(DateTime time) =>
      '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}
