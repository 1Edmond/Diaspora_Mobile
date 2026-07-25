import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../controllers/procedure_completion_notifier.dart';
import '../controllers/procedures_notifier.dart';
import '../../data/models/procedure_model.dart';
import '../../../documents/presentation/controllers/document_providers.dart';

class ProcedureOutputDocumentsSheet extends ConsumerStatefulWidget {
  final String procedureId;
  final ProcedureModel procedure;
  final ProcedureDocMode mode;
  final List<String> docTypeIds;

  const ProcedureOutputDocumentsSheet({
    required this.procedureId,
    required this.procedure,
    this.mode = ProcedureDocMode.complete,
    required this.docTypeIds,
    super.key,
  });

  @override
  ConsumerState<ProcedureOutputDocumentsSheet> createState() =>
      _ProcedureOutputDocumentsSheetState();
}

class _ProcedureOutputDocumentsSheetState
    extends ConsumerState<ProcedureOutputDocumentsSheet> {
  final Map<int, TextEditingController> _issuedByControllers = {};

  @override
  void dispose() {
    for (final c in _issuedByControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int index, String? value) {
    if (_issuedByControllers.containsKey(index)) {
      return _issuedByControllers[index]!;
    }
    final c = TextEditingController(text: value);
    _issuedByControllers[index] = c;
    return c;
  }

  bool _allMetadataFilled() {
    final state = ref.read(procedureCompletionProvider(widget.docTypeIds));
    for (final slot in state.slots) {
      if (!slot.hasFile && !slot.isUploaded) continue;
      if (slot.expiresAt == null || slot.issuedAt == null || (slot.issuedBy == null || slot.issuedBy!.trim().isEmpty)) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final completionState = ref.watch(
      procedureCompletionProvider(widget.docTypeIds),
    );
    final docTypesAsync = ref.watch(documentTypesProvider);
    final docTypes = docTypesAsync.valueOrNull ?? [];
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    String resolveTypeName(String id) {
      final match = docTypes.where((t) => t.id == id).firstOrNull;
      return match?.name ?? id.substring(0, 8);
    }

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 32 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.getDivider(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.upload_file, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Documents à fournir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextMain(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${completionState.uploadedCount}/${completionState.totalCount} documents uploadés',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completionState.totalCount > 0
                  ? completionState.uploadedCount / completionState.totalCount
                  : 0,
              minHeight: 6,
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: completionState.docTypeIds.length,
              itemBuilder: (context, index) {
                final docTypeId = completionState.docTypeIds[index];
                final typeName = resolveTypeName(docTypeId);
                final slot = completionState.slots[index];
                final isLocked = (completionState.isUploading ||
                        completionState.isCompleting) &&
                    !slot.isUploaded;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildDocumentCard(
                    context,
                    index,
                    typeName,
                    slot,
                    isLocked,
                    completionState.isUploading || completionState.isCompleting,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (completionState.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        size: 18, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        completionState.error!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: completionState.allFilesPicked &&
                      !completionState.isUploading &&
                      !completionState.isCompleting &&
                      _allMetadataFilled()
                  ? () => _onComplete(context)
                  : null,
              icon: completionState.isUploading || completionState.isCompleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                completionState.isUploading
                    ? 'Upload en cours...'
                    : completionState.isCompleting
                        ? 'Finalisation...'
                        : widget.mode == ProcedureDocMode.start
                            ? 'Commencer la procédure'
                            : 'Terminer la procédure',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.getTextSecondary(context).withValues(alpha: 0.15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    int index,
    String typeName,
    DocumentSlot slot,
    bool isLocked,
    bool isProcessing,
  ) {
    final notifier = ref.read(
      procedureCompletionProvider(widget.docTypeIds).notifier,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: slot.isUploaded
            ? AppColors.success.withValues(alpha: 0.05)
            : slot.hasFile
                ? AppColors.info.withValues(alpha: 0.05)
                : AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: slot.isUploaded
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.getDivider(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: slot.isUploaded
                      ? AppColors.success.withValues(alpha: 0.15)
                      : slot.hasFile
                          ? AppColors.info.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: slot.isUploaded
                      ? const Icon(Icons.check_circle,
                          size: 18, color: AppColors.success)
                      : slot.hasFile
                          ? const Icon(Icons.hourglass_top,
                              size: 16, color: AppColors.info)
                          : Icon(Icons.description_outlined,
                              size: 16,
                              color: AppColors.getTextSecondary(context)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextMain(context),
                      ),
                    ),
                    if (slot.file != null)
                      Text(
                        slot.file!.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.getTextSecondary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (slot.isUploaded)
                const Icon(Icons.check_circle,
                    size: 22, color: AppColors.success)
              else if (isLocked)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                TextButton.icon(
                  onPressed: () => notifier.pickFile(index),
                  icon: Icon(Icons.attach_file,
                      size: 16, color: AppColors.primary),
                  label: Text(
                    slot.hasFile ? 'Changer' : 'Choisir',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
            ],
          ),
          if (slot.hasFile && !slot.isUploaded && !isProcessing) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildMetadataFields(context, index, slot, notifier),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataFields(
    BuildContext context,
    int index,
    DocumentSlot slot,
    ProcedureCompletionNotifier notifier,
  ) {
    return Column(
      children: [
        _buildDateField(
          context,
          label: "Date d'expiration",
          value: slot.expiresAt,
          icon: Icons.calendar_today,
          onPick: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: slot.expiresAt ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
            );
            if (date != null) notifier.setExpiresAt(index, date);
          },
          onClear: () => notifier.setExpiresAt(index, null),
        ),
        const SizedBox(height: 10),
        _buildDateField(
          context,
          label: 'Date de délivrance',
          value: slot.issuedAt,
          icon: Icons.date_range,
          onPick: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: slot.issuedAt ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) notifier.setIssuedAt(index, date);
          },
          onClear: () => notifier.setIssuedAt(index, null),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          context,
          index: index,
          label: 'Délivré par',
          value: slot.issuedBy,
          hint: 'Administration, autorité...',
          icon: Icons.person_outline,
          onChanged: (v) => notifier.setIssuedBy(index, v),
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.getTextSecondary(context)),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.getDivider(context)),
              ),
              child: Text(
                value != null
                    ? '${value.day}/${value.month}/${value.year}'
                    : label,
                style: TextStyle(
                  fontSize: 13,
                  color: value != null
                      ? AppColors.getTextMain(context)
                      : AppColors.getTextSecondary(context),
                ),
              ),
            ),
          ),
        ),
        if (value != null)
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onClear,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32),
            color: AppColors.getTextSecondary(context),
          ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required int index,
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    final controller = _controllerFor(index, value);

    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.getTextSecondary(context)),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(context),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.getDivider(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.getDivider(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextMain(context),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _onComplete(BuildContext context) async {
    final notifier = ref.read(
      procedureCompletionProvider(widget.docTypeIds).notifier,
    );
    final upId = ref.read(proceduresProvider).userProcedureIds[widget.procedureId];
    final success = await notifier.uploadAndComplete(
      widget.procedureId,
      mode: widget.mode,
      userProcedureId: upId,
    );

    if (success && mounted) {
      context.pop();
      ref.read(proceduresProvider.notifier).fetch();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.mode == ProcedureDocMode.start
                ? 'Procédure démarrée avec succès'
                : 'Procédure terminée avec succès',
          ),
        ),
      );
    }
  }
}
