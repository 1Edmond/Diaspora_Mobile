import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../presentation/controllers/document_providers.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du document'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Supprimer',
          ),
        ],
      ),
      body: documentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Document non trouvé',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            ),
        data: (document) {
          if (document == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Document non trouvé',
                    style: Theme.of(context).textTheme.titleMedium,
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Document preview
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child:
                      document.isPdf
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  size: 64,
                                  color: Colors.red.shade300,
                                ),
                                const SizedBox(height: 16),
                                const Text('Aperçu PDF'),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _viewPdf(document.url),
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Ouvrir le PDF'),
                                ),
                              ],
                            ),
                          )
                          : document.isImage
                          ? Image.network(
                            document.url,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Impossible de charger l\'image',
                                      ),
                                    ],
                                  ),
                                ),
                          )
                          : Center(
                            child: Icon(
                              Icons.file_present,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                          ),
                ),
                const SizedBox(height: 24),
                // Document information
                Text(
                  'Informations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Titre', document.title),
                _buildInfoRow('Catégorie', document.category.label),
                if (document.description != null)
                  _buildInfoRow('Description', document.description!),
                _buildInfoRow('Taille', document.formattedFileSize),
                _buildInfoRow(
                  'Date d\'upload',
                  _formatDate(document.uploadedAt),
                ),
                if (document.expiresAt != null) ...[
                  _buildInfoRow(
                    'Date d\'expiration',
                    _formatDate(document.expiresAt!),
                  ),
                  if (document.isExpired)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Ce document a expiré',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 24),
                // Verification status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        document.isVerified
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                    border: Border.all(
                      color:
                          document.isVerified
                              ? Colors.green.shade300
                              : Colors.orange.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        document.isVerified ? Icons.check_circle : Icons.info,
                        color:
                            document.isVerified
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          document.isVerified
                              ? 'Document vérifié'
                              : 'Document non vérifié',
                          style: TextStyle(
                            color:
                                document.isVerified
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // OCR/Text extraction
                if (!_showExtractedText)
                  ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(textExtractionProvider.notifier)
                          .extractText(widget.documentId);
                      setState(() => _showExtractedText = true);
                    },
                    icon: const Icon(Icons.analytics),
                    label: const Text('Extraire le texte (OCR)'),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Texte extrait',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              ref.read(textExtractionProvider.notifier).reset();
                              setState(() => _showExtractedText = false);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      textExtractionAsync.when(
                        loading:
                            () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        error:
                            (error, st) => Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                border: Border.all(color: Colors.red.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Erreur lors de l\'extraction: ${error.toString()}',
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                        data:
                            (text) => Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SelectableText(
                                text ?? 'Aucun texte détecté',
                                style: const TextStyle(height: 1.5),
                              ),
                            ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewPdf(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: const Text('Affichage PDF')),
              body: PdfPreview(
                build: (format) async {
                  final pdf = pw.Document();
                  pdf.addPage(
                    pw.Page(
                      build: (pw.Context context) {
                        return pw.Center(child: pw.Text('Aperçu PDF'));
                      },
                    ),
                  );
                  return pdf.save();
                },
              ),
            ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Supprimer le document'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer ce document ? Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(documentDeleteProvider.notifier)
                      .deleteDocument(widget.documentId);
                  context.pop();
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document supprimé')),
                  );
                },
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
