import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../../../core/theme/design_system.dart';
import '../controllers/document_providers.dart';
import '../../data/models/document_type_model.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';

class UploadDocumentScreen extends ConsumerStatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  ConsumerState<UploadDocumentScreen> createState() =>
      _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends ConsumerState<UploadDocumentScreen> {
  late TextEditingController _descriptionController;
  DocumentTypeModel? _selectedType;
  DateTime? _expirationDate;
  DateTime? _issuedDate;
  final _issuedByController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _hasExpiration = false;
  bool _hasIssuedDate = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _issuedByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadAsync = ref.watch(documentUploadProvider);
    final typesAsync = ref.watch(documentTypesProvider);

    ref.listen(documentUploadProvider, (previous, next) {
      next.maybeWhen(
        data: (document) {
          if (document != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Document uploadé avec succès')),
            );
            ref.read(documentsListProvider.notifier).refresh();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.pop();
            });
          }
        },
        error: (error, stackTrace) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        orElse: () {},
      );
    });

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),

                  _buildSectionLabel('Fichier'),
                  const SizedBox(height: 12),
                  _buildFilePicker().animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

                  const SizedBox(height: 28),
                  _buildSectionLabel('Type de document'),
                  const SizedBox(height: 12),
                  _buildTypeDropdown(typesAsync).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: 28),
                  _buildSectionLabel('Description (optionnelle)'),
                  const SizedBox(height: 12),
                  _buildDescriptionField().animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                  const SizedBox(height: 28),
                  _buildCheckboxRow(
                    'Date d\'expiration',
                    _hasExpiration,
                    (v) => setState(() {
                      _hasExpiration = v ?? false;
                      if (!_hasExpiration) _expirationDate = null;
                    }),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  if (_hasExpiration) ...[
                    const SizedBox(height: 12),
                    _buildDatePicker(
                      'Sélectionnez une date',
                      _expirationDate,
                      () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _expirationDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (date != null) setState(() => _expirationDate = date);
                      },
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
                  ],

                  const SizedBox(height: 16),
                  _buildCheckboxRow(
                    'Date de délivrance',
                    _hasIssuedDate,
                    (v) => setState(() {
                      _hasIssuedDate = v ?? false;
                      if (!_hasIssuedDate) _issuedDate = null;
                    }),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                  if (_hasIssuedDate) ...[
                    const SizedBox(height: 12),
                    _buildDatePicker(
                      'Sélectionnez une date',
                      _issuedDate,
                      () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _issuedDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => _issuedDate = date);
                      },
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
                  ],

                  const SizedBox(height: 24),
                  _buildSectionLabel('Délivré par (optionnel)'),
                  const SizedBox(height: 12),
                  _buildIssuedByField().animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

                  const SizedBox(height: 36),
                  _buildSubmitButton(uploadAsync).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
                  const SizedBox(height: 12),
                  _buildCancelButton().animate().fadeIn(delay: 750.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.04),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.getTextMain(context)),
          onPressed: () => context.pop(),
        ),
        const Spacer(),
        Text(
          'Ajouter un document',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMain(context),
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.getTextMain(context),
      ),
    );
  }

  Widget _buildFilePicker() {
    return NeumorphicContainer(
      width: double.infinity,
      borderRadius: 16,
      padding: const EdgeInsets.all(24),
      child: GestureDetector(
        onTap: _pickFile,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedFile == null) ...[
              Icon(Icons.cloud_upload_outlined, size: 52, color: AppColors.primary.withValues(alpha: 0.7)),
              const SizedBox(height: 12),
              Text(
                'Cliquez pour sélectionner un fichier',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.getTextMain(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'PDF, Images ou Documents',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 13,
                ),
              ),
            ] else ...[
              Icon(Icons.check_circle, size: 52, color: AppColors.success),
              const SizedBox(height: 12),
              Text(
                _selectedFile!.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextMain(context),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatFileSize(_selectedFile!.size),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _pickFile,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Changer'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDropdown(AsyncValue<List<DocumentTypeModel>> typesAsync) {
    return typesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Text('Erreur: $e', style: TextStyle(color: AppColors.error, fontSize: 13)),
      data: (types) => NeumorphicContainer(
        isPressed: true,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonFormField<DocumentTypeModel>(
          initialValue: _selectedType,
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.category_rounded, color: AppColors.primary),
          ),
          hint: Text(
            'Sélectionnez un type',
            style: TextStyle(color: AppColors.getTextSecondary(context)),
          ),
          isExpanded: true,
          items: types
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.name, style: TextStyle(color: AppColors.getTextMain(context))),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() => _selectedType = value);
          },
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return NeumorphicContainer(
      isPressed: true,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: _descriptionController,
        maxLines: 3,
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.description_outlined, color: AppColors.primary),
          hintText: 'Ajoutez une description',
        ),
        style: TextStyle(color: AppColors.getTextMain(context)),
      ),
    );
  }

  Widget _buildCheckboxRow(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextMain(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String hint, DateTime? selectedDateValue, VoidCallback onTap) {
    return NeumorphicContainer(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                selectedDateValue == null
                    ? hint
                    : '${selectedDateValue.day}/${selectedDateValue.month}/${selectedDateValue.year}',
                style: TextStyle(
                  color: selectedDateValue == null
                      ? AppColors.getTextSecondary(context)
                      : AppColors.getTextMain(context),
                  fontSize: 15,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.getTextSecondary(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuedByField() {
    return NeumorphicContainer(
      isPressed: true,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: TextField(
        controller: _issuedByController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primary),
          hintText: 'Délivré par',
        ),
        style: TextStyle(color: AppColors.getTextMain(context)),
      ),
    );
  }

  Widget _buildSubmitButton(AsyncValue uploadAsync) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: _selectedFile == null || _selectedType == null || uploadAsync is AsyncLoading
            ? null
            : _submitForm,
        child: uploadAsync is AsyncLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Uploader le document',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.getTextSecondary(context),
          side: BorderSide(color: AppColors.getTextSecondary(context).withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () => context.pop(),
        child: const Text(
          'Annuler',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _selectedFile = result.files.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitForm() {
    if (_selectedFile == null || _selectedType == null) return;

    final activeProfile = ref.read(activeProfileProvider);
    if (activeProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun profil actif. Veuillez d\'abord sélectionner un profil.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(documentUploadProvider.notifier).uploadDocument(
          profileId: activeProfile.id,
          documentTypeId: _selectedType!.id,
          filePath: _selectedFile!.path!,
          fileName: _selectedFile!.name,
          expiresAt: _hasExpiration ? _expirationDate : null,
          issuedAt: _hasIssuedDate ? _issuedDate : null,
          issuedBy: _issuedByController.text.isNotEmpty
              ? _issuedByController.text
              : null,
        );
  }

  String _formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var suffixIndex = 0;
    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }
    return '${size.toStringAsFixed(2)} ${suffixes[suffixIndex]}';
  }
}
