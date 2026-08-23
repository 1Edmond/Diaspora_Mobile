import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/design_system.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  File? _selectedMedia;
  bool _isVideo = false;
  final _captionCtrl = TextEditingController();

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, {bool video = false}) async {
    final picker = ImagePicker();
    try {
      if (video) {
        final picked = await picker.pickVideo(source: source);
        if (picked != null) {
          setState(() {
            _selectedMedia = File(picked.path);
            _isVideo = true;
          });
        }
      } else {
        final picked = await picker.pickImage(source: source);
        if (picked != null) {
          setState(() {
            _selectedMedia = File(picked.path);
            _isVideo = false;
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E1621) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: AppColors.getTextMain(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Nouvelle story',
          style: TextStyle(
            color: AppColors.getTextMain(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_selectedMedia != null)
            TextButton(
              onPressed: _publishStory,
              child: Text(
                'Publier',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: _selectedMedia == null
          ? _buildPicker(isDark)
          : _buildPreview(isDark),
    );
  }

  Widget _buildPicker(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.add_photo_alternate_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ajouter à votre story',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextMain(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Photo ou vidéo',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PickerButton(
                icon: Icons.photo_library_rounded,
                label: 'Galerie',
                onTap: () => _pickMedia(ImageSource.gallery),
                isDark: isDark,
              ),
              const SizedBox(width: 16),
              _PickerButton(
                icon: Icons.camera_alt_rounded,
                label: 'Caméra',
                onTap: () => _pickMedia(ImageSource.camera),
                isDark: isDark,
              ),
              const SizedBox(width: 16),
              _PickerButton(
                icon: Icons.videocam_rounded,
                label: 'Vidéo',
                onTap: () => _pickMedia(ImageSource.gallery, video: true),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _isVideo
                  ? Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(Icons.play_circle_fill_rounded,
                            size: 64, color: Colors.white70),
                      ),
                    )
                  : Image.file(
                      _selectedMedia!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.withValues(alpha: 0.2),
                        child: const Center(
                          child: Icon(Icons.broken_image_rounded,
                              size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: TextField(
                    controller: _captionCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Ajouter une légende...',
                      hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _publishStory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Story publiée !')),
    );
    context.pop();
  }
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
