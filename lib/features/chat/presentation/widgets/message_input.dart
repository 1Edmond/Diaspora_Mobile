import 'package:flutter/material.dart';
import '../../../../core/theme/design_system.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
      color: isDark ? const Color(0xFF17212B) : Colors.white,
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: IconButton(
                icon: Icon(Icons.attach_file_rounded,
                    color: AppColors.getTextSecondary(context), size: 24),
                onPressed: () {},
              ),
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        minLines: 1,
                        maxLines: 5,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.getTextMain(context),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(
                            color: AppColors.getTextSecondary(context),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: IconButton(
                        icon: Icon(Icons.emoji_emotions_outlined,
                            color: AppColors.getTextSecondary(context),
                            size: 24),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                final isEmpty = value.text.trim().isEmpty;
                return Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isEmpty
                        ? AppColors.getTextSecondary(context)
                            .withValues(alpha: 0.1)
                        : const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isEmpty ? Icons.mic_rounded : Icons.send_rounded,
                      size: 20,
                      color: isEmpty
                          ? AppColors.getTextSecondary(context)
                          : Colors.white,
                    ),
                    onPressed: isEmpty ? null : _send,
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
