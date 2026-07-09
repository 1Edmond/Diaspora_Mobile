import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../domain/entities/message.dart';
import '../../../../core/constants/enums.dart';

class MessageInput extends StatefulWidget {
  final Function(String, MessageType, {String? mediaUrl, int? duration})
  onSendMessage;
  final Function(String, int) onSendVoiceMessage;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    required this.onSendVoiceMessage,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        borderRadius: 30,
        opacity: 0.9,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.emoji_emotions_outlined,
                color: AppColors.getTextSecondary(context),
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.getTextSecondary(context),
              ),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Votre message...',
                    hintStyle: TextStyle(color: AppColors.getTextSecondary(context)),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ),
            ),
            _buildSendButton(),
          ],
        ),
      ).animate().slideY(begin: 0.5, curve: Curves.easeOutBack),
    );
  }

  Widget _buildSendButton() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, child) {
        final isTextEmpty = value.text.trim().isEmpty;
        return NeumorphicContainer(
          width: 48,
          height: 48,
          borderRadius: 24,
          color: isTextEmpty ? AppColors.getBackground(context) : AppColors.primary,
          child: IconButton(
            icon: Icon(
              isTextEmpty ? Icons.mic_rounded : Icons.send_rounded,
              color: isTextEmpty ? AppColors.getTextSecondary(context) : Colors.white,
              size: 20,
            ),
            onPressed: () {
              if (isTextEmpty) {
                // mock voice
              } else {
                _sendTextMessage(_controller.text);
              }
            },
          ),
        );
      },
    );
  }

  void _sendTextMessage(String text) {
    if (text.trim().isEmpty) return;
    widget.onSendMessage(text.trim(), MessageType.TEXT);
    _controller.clear();
  }
}
