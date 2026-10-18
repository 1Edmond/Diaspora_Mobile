import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/design_system.dart';

class OtpCodeInputDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final Future<void> Function(String otpCode, String? proofUrl) onConfirm;

  const OtpCodeInputDialog({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel = 'Valider le code OTP',
    required this.onConfirm,
  });

  @override
  State<OtpCodeInputDialog> createState() => _OtpCodeInputDialogState();
}

class _OtpCodeInputDialogState extends State<OtpCodeInputDialog> {
  final TextEditingController _otpController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _errorMessage;
  String? _pickedPhotoPath;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Prendre une photo justificative',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  title: const Text('Appareil photo (Recommandé)'),
                  subtitle: const Text('Prendre en photo le colis lors de la remise'),
                  onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                  title: const Text('Galerie de photos'),
                  onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _pickedPhotoPath = picked.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'accéder à la caméra : $e')),
        );
      }
    }
  }

  Future<void> _handleConfirm() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Veuillez saisir les 6 chiffres du code OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm(code, _pickedPhotoPath);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Code OTP invalide ou expiré';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // OTP Input
            TextFormField(
              key: const Key('otp_input_field'),
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '••••••',
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: isDark ? Colors.black26 : Colors.grey[100],
              ),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],

            const SizedBox(height: 16),

            // Photo justificative
            if (_pickedPhotoPath != null)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: !kIsWeb
                          ? Image.file(
                              File(_pickedPhotoPath!),
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              _pickedPhotoPath!,
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                          onPressed: () => setState(() => _pickedPhotoPath = null),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Preuve photo jointe',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                key: const Key('take_proof_photo_button'),
                onPressed: _pickPhoto,
                icon: const Icon(Icons.camera_alt_rounded, size: 20),
                label: const Text(
                  'Prendre photo justificative (remise/pesée)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    key: const Key('submit_otp_button'),
                    onPressed: _isLoading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            widget.actionLabel,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
