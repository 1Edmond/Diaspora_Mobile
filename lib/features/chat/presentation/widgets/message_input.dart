import 'package:flutter/material.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../core/constants/enums.dart';

class MessageInput extends StatefulWidget {
  final Function(String, MessageType, {String? mediaUrl, int? duration}) onSendMessage;
  final Function(String, int) onSendVoiceMessage;

  const MessageInput({super.key, required this.onSendMessage, required this.onSendVoiceMessage});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage(text, MessageType.TEXT);
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: IconButton(
                icon: Icon(Icons.add_circle_outline_rounded, color: AppColors.getTextSecondary(context)),
                onPressed: () {},
              ),
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.getTextSecondary(context).withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: IconButton(
                        icon: Icon(Icons.emoji_emotions_outlined, color: AppColors.getTextSecondary(context)),
                        onPressed: () {},
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(color: AppColors.getTextSecondary(context)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                final isEmpty = value.text.trim().isEmpty;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isEmpty ? AppColors.getTextSecondary(context).withValues(alpha: 0.1) : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isEmpty ? Icons.mic_rounded : Icons.send_rounded,
                        size: 20,
                        color: isEmpty ? AppColors.getTextSecondary(context) : Colors.white,
                      ),
                      onPressed: isEmpty ? null : _send,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
