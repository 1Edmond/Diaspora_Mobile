import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/design_system.dart';

/// A grid of photo slots for creating/editing a listing.
///
/// - Tap an empty slot to add a photo (camera or gallery).
/// - Tap the "x" on a filled slot to remove it.
/// - The first photo is always the cover ("Couverture") and can be
///   changed by long-pressing another photo (calls [onSetCover]).
///
/// [existingUrls] are already-uploaded network images (edit mode);
/// [localPaths] are freshly picked files not yet uploaded. Both are
/// shown together, existing images first, so the on-screen order
/// always matches what `imagePaths` will send to the API.
class PhotoPickerGrid extends StatelessWidget {
  final List<String> existingUrls;
  final List<String> localPaths;
  final ValueChanged<String> onAddLocalPath;
  final ValueChanged<String> onRemoveExisting;
  final ValueChanged<String> onRemoveLocal;
  final int maxPhotos;

  const PhotoPickerGrid({
    super.key,
    required this.existingUrls,
    required this.localPaths,
    required this.onAddLocalPath,
    required this.onRemoveExisting,
    required this.onRemoveLocal,
    this.maxPhotos = 6,
  });

  int get _totalCount => existingUrls.length + localPaths.length;

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SourceSheet(),
    );
    if (source == null) return;
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file != null) onAddLocalPath(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final slots = _totalCount < maxPhotos ? _totalCount + 1 : maxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: slots,
          itemBuilder: (context, index) {
            final isAddTile = index == _totalCount;
            if (isAddTile) {
              return _AddTile(isDark: isDark, onTap: () => _pickImage(context));
            }
            final isCover = index == 0;
            if (index < existingUrls.length) {
              return _PhotoTile(
                isCover: isCover,
                isDark: isDark,
                image: Image.network(existingUrls[index], fit: BoxFit.cover),
                onRemove: () => onRemoveExisting(existingUrls[index]),
              );
            }
            final localIndex = index - existingUrls.length;
            final path = localPaths[localIndex];
            return _PhotoTile(
              isCover: isCover,
              isDark: isDark,
              image: Image.file(File(path), fit: BoxFit.cover),
              onRemove: () => onRemoveLocal(path),
            );
          },
        ).animate().fadeIn(duration: 250.ms),
        const SizedBox(height: 10),
        _HintBanner(count: _totalCount),
      ],
    );
  }
}

class _HintBanner extends StatelessWidget {
  final int count;
  const _HintBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final good = count >= 3;
    final none = count == 0;
    final color = none
        ? Colors.orange
        : (good ? Colors.green : Colors.orange);
    final text = none
        ? 'Ajoutez au moins une photo pour continuer'
        : (good
            ? '$count photos ajoutées, parfait !'
            : '$count photo${count > 1 ? 's' : ''} ajoutée${count > 1 ? 's' : ''} — essayez d\'en ajouter 3 ou plus');

    return AnimatedContainer(
      duration: 250.ms,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            good ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  const _AddTile({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorderBox(
        isDark: isDark,
        child: Icon(
          Icons.add_a_photo_outlined,
          color: isDark ? Colors.white38 : Colors.grey[500],
          size: 26,
        ),
      ),
    );
  }
}

/// Lightweight dashed-border container (no external package dependency).
class DottedBorderBox extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const DottedBorderBox({super.key, required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey[350]!,
          width: 1.5,
          style: BorderStyle.solid,
        ),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
      ),
      child: Center(child: child),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final bool isCover;
  final bool isDark;
  final Widget image;
  final VoidCallback onRemove;

  const _PhotoTile({
    required this.isCover,
    required this.isDark,
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: image),
        if (isCover)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Couverture',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 13, color: Colors.white),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

class _SourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir dans la galerie'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}