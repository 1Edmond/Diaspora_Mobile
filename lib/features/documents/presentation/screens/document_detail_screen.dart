import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../data/models/document_dto_model.dart';
import '../../data/models/document_type_model.dart';
import '../../data/models/document_status.dart';
import '../controllers/document_providers.dart';

class DocumentDetailScreen extends ConsumerStatefulWidget {
  final String documentId;

  const DocumentDetailScreen({required this.documentId, super.key});

  @override
  ConsumerState<DocumentDetailScreen> createState() =>
      _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  bool _showExtractedText = false;

  @override
  Widget build(BuildContext context) {
    final documentAsync = ref.watch(documentDetailProvider(widget.documentId));
    final textExtractionAsync = ref.watch(textExtractionProvider);
    final typesAsync = ref.watch(documentTypesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: documentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildErrorState(),
        data: (document) {
          if (document == null) return _buildErrorState();
          return _buildContent(context, document, textExtractionAsync, typesAsync);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error.withValues(alpha: 0.6)),
          const SizedBox(height: 16),
          Text(
            'Document non trouvé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextMain(context),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, DocumentDtoModel document, AsyncValue<String?> textExtractionAsync, AsyncValue<List<DocumentTypeModel>> typesAsync) {
    final isExpired = document.isExpired;

    return Stack(
      children: [
        _buildBackground(),
        CustomScrollView(
          slivers: [
            _buildAppBar(context, document),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPreviewCard(context, document),
                    const SizedBox(height: 24),
                    _buildInfoCard(context, document, isExpired, typesAsync),
                    const SizedBox(height: 24),
                    if (document.status == DocumentStatus.rejected && document.rejectionReason != null)
                      _buildRejectionBanner(context, document.rejectionReason!),
                    if (document.rejectionReason != null && document.status == DocumentStatus.rejected)
                      const SizedBox(height: 24),
                    if (document.validatedAt != null)
                      _buildValidationCard(context, document),
                    if (document.validatedAt != null)
                      const SizedBox(height: 24),
                    if (document.issuedAt != null || document.issuedBy != null)
                      _buildIssuanceCard(context, document),
                    if (document.issuedAt != null || document.issuedBy != null)
                      const SizedBox(height: 24),
                    _buildExtractedTextSection(context, textExtractionAsync),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: -120,
      right: -80,
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.04),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, DocumentDtoModel document) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Text(
        document.documentTypeName ?? 'Détail du document',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _showDeleteConfirmation(context),
          tooltip: 'Supprimer',
        ),
      ],
    );
  }

  Widget _buildPreviewCard(BuildContext context, DocumentDtoModel document) {
    return NeumorphicContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.getCardBackground(context),
                  AppColors.primary.withValues(alpha: 0.03),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: document.isPdf
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, size: 64, color: AppColors.error.withValues(alpha: 0.6)),
                        const SizedBox(height: 12),
                        Text(
                          'Document PDF',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : document.isImage && document.filePath != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          document.filePath!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 220,
                          errorBuilder: (_, __, ___) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  'Impossible de charger l\'image',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.file_present, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text(document.fileName ?? 'Fichier', style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
          ),
          if (document.fileName != null || document.mimeType != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.getDivider(context))),
              ),
              child: Row(
                children: [
                  Icon(Icons.insert_drive_file, size: 18, color: AppColors.getTextSecondary(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      document.fileName ?? 'Fichier',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getTextMain(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (document.mimeType != null)
                    Text(
                      document.formattedMimeType,
                      style: TextStyle(fontSize: 11, color: AppColors.getTextSecondary(context)),
                    ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, duration: 400.ms);
  }

  String _resolveTypeName(DocumentDtoModel document, AsyncValue<List<DocumentTypeModel>> typesAsync) {
    if (document.documentTypeName != null) return document.documentTypeName!;
    final types = typesAsync.valueOrNull;
    if (types == null) return 'Type ${document.documentTypeId.substring(0, 8)}...';
    final match = types.where((t) => t.id == document.documentTypeId).firstOrNull;
    return match?.name ?? 'Type ${document.documentTypeId.substring(0, 8)}...';
  }

  Widget _buildInfoCard(BuildContext context, DocumentDtoModel document, bool isExpired, AsyncValue<List<DocumentTypeModel>> typesAsync) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Informations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextMain(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(context, 'Type', _resolveTypeName(document, typesAsync)),
          if (document.documentTypeCode != null)
            _infoRow(context, 'Code', document.documentTypeCode!),
          _infoRow(context, 'Statut', document.status.label),
          _infoRow(context, 'Taille', document.formattedFileSize),
          _infoRow(context, 'Créé le', _formatDate(document.createdAt)),
          if (document.expiresAt != null) ...[
            const Divider(height: 24),
            _infoRow(context, 'Expire le', _formatDate(document.expiresAt!)),
            if (isExpired)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.error),
                    const SizedBox(width: 10),
                    Text(
                      'Ce document a expiré',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Expire dans ${document.expiresInDays} jours',
                  style: TextStyle(
                    fontSize: 12,
                    color: document.expiresInDays <= 30 ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
          if (document.validatedAt != null) ...[
            const Divider(height: 24),
            _infoRow(context, 'Validé le', _formatDate(document.validatedAt!)),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.05, duration: 400.ms);
  }

  Widget _buildRejectionBanner(BuildContext context, String reason) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cancel_rounded, color: AppColors.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document rejeté',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.05, duration: 400.ms);
  }

  Widget _buildValidationCard(BuildContext context, DocumentDtoModel document) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified, color: AppColors.success, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document validé',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Validé le ${_formatDate(document.validatedAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.05, duration: 400.ms);
  }

  Widget _buildIssuanceCard(BuildContext context, DocumentDtoModel document) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_ind, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Délivrance',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextMain(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (document.issuedAt != null)
            _infoRow(context, 'Délivré le', _formatDate(document.issuedAt!)),
          if (document.issuedBy != null)
            _infoRow(context, 'Délivré par', document.issuedBy!),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.05, duration: 400.ms);
  }

  Widget _buildExtractedTextSection(BuildContext context, AsyncValue<String?> textExtractionAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_showExtractedText)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(textExtractionProvider.notifier).extractText(widget.documentId);
                setState(() => _showExtractedText = true);
              },
              icon: const Icon(Icons.analytics),
              label: const Text('Extraire le texte (OCR)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(begin: 0.05, duration: 400.ms)
        else
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.text_snippet, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Texte extrait',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextMain(context),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        ref.read(textExtractionProvider.notifier).reset();
                        setState(() => _showExtractedText = false);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                textExtractionAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, _) => Text(
                    'Erreur: $error',
                    style: TextStyle(color: AppColors.error),
                  ),
                  data: (text) => SelectableText(
                    text ?? 'Aucun texte détecté',
                    style: const TextStyle(height: 1.6),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.05, duration: 400.ms),
      ],
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextMain(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le document'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce document ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(documentDeleteProvider.notifier).deleteDocument(widget.documentId);
              ctx.pop();
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document supprimé')),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}