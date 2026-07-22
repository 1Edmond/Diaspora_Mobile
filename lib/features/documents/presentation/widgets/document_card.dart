import 'package:flutter/material.dart';
import '../../data/models/document_dto_model.dart';
import '../../data/models/document_status.dart';

class DocumentStatusBadge extends StatelessWidget {
  final DocumentStatus status;

  const DocumentStatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return Colors.orange;
      case DocumentStatus.active:
        return Colors.green;
      case DocumentStatus.expired:
        return Colors.red;
      case DocumentStatus.rejected:
        return Colors.grey;
    }
  }
}

class DocumentCard extends StatelessWidget {
  final DocumentDtoModel document;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const DocumentCard({
    required this.document,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: _buildIcon(),
        title: Text(
          document.documentTypeName ?? document.fileName ?? 'Document',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            DocumentStatusBadge(status: document.status),
            const SizedBox(height: 4),
            Text(
              '${document.formattedFileSize} • ${_formatDate(document.uploadedAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (document.isExpired)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Expiré',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (document.expiresAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Expire dans ${document.expiresInDays} jours',
                  style: TextStyle(
                    fontSize: 12,
                    color: document.expiresInDays <= 30 ? Colors.orange : Colors.green,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (document.isVerified)
              const PopupMenuItem(
                enabled: false,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text('Vérifié'),
                  ],
                ),
              ),
            PopupMenuItem(
              onTap: onDelete,
              child: const Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Text('Supprimer'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    if (document.isPdf) {
      icon = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (document.isImage) {
      icon = Icons.image;
      color = Colors.blue;
    } else {
      icon = Icons.file_present;
      color = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: color),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class DocumentEmptyState extends StatelessWidget {
  final VoidCallback onAddDocument;

  const DocumentEmptyState({required this.onAddDocument, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.file_present, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Aucun document',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez vos documents importants',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddDocument,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un document'),
          ),
        ],
      ),
    );
  }
}
