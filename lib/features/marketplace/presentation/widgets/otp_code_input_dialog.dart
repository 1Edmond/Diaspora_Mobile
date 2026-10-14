import 'package:flutter/material.dart';
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
  bool _isLoading = false;
  String? _errorMessage;
  String? _simulatedPhotoPath;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
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
      await widget.onConfirm(code, _simulatedPhotoPath);
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

            // Photo justificative button
            OutlinedButton.icon(
              key: const Key('take_proof_photo_button'),
              onPressed: () {
                setState(() {
                  _simulatedPhotoPath = 'proof_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
                });
              },
              icon: Icon(
                _simulatedPhotoPath != null
                    ? Icons.check_circle_rounded
                    : Icons.camera_alt_rounded,
                color: _simulatedPhotoPath != null ? Colors.green : null,
                size: 20,
              ),
              label: Text(
                _simulatedPhotoPath != null
                    ? 'Photo de justificatif jointe'
                    : 'Prendre photo justificative (pesée/remise)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _simulatedPhotoPath != null ? Colors.green : null,
                ),
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
