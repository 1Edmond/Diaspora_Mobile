import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
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
  final _picker = ImagePicker();
  final _recorder = AudioRecorder();

  bool _showEmojiPicker = false;
  bool _isRecording = false;
  bool _cancelRecording = false;
  double _recordDragX = 0;
  DateTime? _recordStart;
  Timer? _recordTimer;
  Duration _recordElapsed = Duration.zero;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _recordTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage(text, MessageType.TEXT);
    _controller.clear();
  }

  void _toggleEmojiPicker() {
    if (!_showEmojiPicker) _focusNode.unfocus();
    setState(() => _showEmojiPicker = !_showEmojiPicker);
  }

  // ── Attachments ──────────────────────────────────────────────────

  void _showAttachmentSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2A3A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Wrap(
            children: [
              _AttachmentTile(
                icon: Icons.photo_library_rounded,
                label: 'Galerie',
                color: Colors.purple,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              _AttachmentTile(
                icon: Icons.camera_alt_rounded,
                label: 'Appareil photo',
                color: Colors.blue,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              _AttachmentTile(
                icon: Icons.insert_drive_file_rounded,
                label: 'Document',
                color: Colors.orange,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickDocument();
                },
              ),
              _AttachmentTile(
                icon: Icons.location_on_rounded,
                label: 'Position',
                color: Colors.green,
                onTap: () {
                  Navigator.of(ctx).pop();
                  // No maps/geolocation package wired yet — sends a
                  // placeholder location message rather than pretending
                  // to share a real one.
                  widget.onSendMessage('Position partagée', MessageType.LOCATION);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    widget.onSendMessage(file.name, MessageType.IMAGE, mediaUrl: file.path);
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;
    widget.onSendMessage(
      result.files.single.name,
      MessageType.DOCUMENT,
      mediaUrl: result.files.single.path,
    );
  }

  // ── Voice recording (hold-to-record, slide left to cancel) ─────────

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) return;
    final dir = Directory.systemTemp;
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    setState(() {
      _isRecording = true;
      _cancelRecording = false;
      _recordDragX = 0;
      _recordStart = DateTime.now();
      _recordElapsed = Duration.zero;
    });
    _recordTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_recordStart == null) return;
      setState(() => _recordElapsed = DateTime.now().difference(_recordStart!));
    });
  }

  Future<void> _stopRecording({required bool send}) async {
    _recordTimer?.cancel();
    final path = await _recorder.stop();
    final duration = _recordElapsed.inSeconds;
    setState(() {
      _isRecording = false;
      _recordDragX = 0;
    });
    if (send && !_cancelRecording && path != null && duration >= 1) {
      widget.onSendVoiceMessage(path, duration);
    } else if (path != null) {
      // Cancelled or too short — discard the recorded file.
      try {
        await File(path).delete();
      } catch (_) {
        // Best-effort cleanup; nothing actionable if this fails.
      }
    }
  }

  String _formatElapsed(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
          color: isDark ? const Color(0xFF17212B) : Colors.white,
          child: SafeArea(
            top: false,
            child: _isRecording ? _buildRecordingRow(isDark) : _buildComposerRow(isDark),
          ),
        ),
        if (_showEmojiPicker)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                _controller.text += emoji.emoji;
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
              },
              config: Config(
                emojiViewConfig: EmojiViewConfig(
                  backgroundColor: isDark ? const Color(0xFF17212B) : Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecordingRow(bool isDark) {
    final willCancel = _recordDragX < -80;
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < 0) {
          setState(() {
            _recordDragX += details.delta.dx;
            _cancelRecording = _recordDragX < -80;
          });
        }
      },
      onHorizontalDragEnd: (_) {
        if (_cancelRecording) {
          _stopRecording(send: false);
        } else {
          setState(() => _recordDragX = 0);
        }
      },
      child: Row(
        children: [
          const Icon(Icons.mic_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Text(
            _formatElapsed(_recordElapsed),
            style: TextStyle(color: AppColors.getTextMain(context), fontSize: 15),
          ),
          const Spacer(),
          Transform.translate(
            offset: Offset(_recordDragX.clamp(-120, 0), 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: willCancel ? Colors.redAccent : AppColors.getTextSecondary(context)),
                Text(
                  willCancel ? 'Relâchez pour annuler' : 'Glissez pour annuler',
                  style: TextStyle(
                    fontSize: 13,
                    color: willCancel ? Colors.redAccent : AppColors.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _stopRecording(send: true),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposerRow(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: IconButton(
            icon: Icon(Icons.attach_file_rounded,
                color: AppColors.getTextSecondary(context), size: 24),
            onPressed: _showAttachmentSheet,
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
                    onTap: () {
                      if (_showEmojiPicker) setState(() => _showEmojiPicker = false);
                    },
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
                    icon: Icon(
                      _showEmojiPicker
                          ? Icons.keyboard_rounded
                          : Icons.emoji_emotions_outlined,
                      color: AppColors.getTextSecondary(context),
                      size: 24,
                    ),
                    onPressed: _toggleEmojiPicker,
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
            return GestureDetector(
              onLongPressStart: isEmpty ? (_) => _startRecording() : null,
              onLongPressEnd: isEmpty ? (_) => _stopRecording(send: true) : null,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isEmpty
                      ? AppColors.getTextSecondary(context).withValues(alpha: 0.1)
                      : const Color(0xFF4CAF50),
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
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.getTextSecondary(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
