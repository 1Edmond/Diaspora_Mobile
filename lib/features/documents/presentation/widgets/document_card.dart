import 'package:flutter/material.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/document_category.dart';

class DocumentCategoryBadge extends StatelessWidget {
  final DocumentCategory category;

  const DocumentCategoryBadge({required this.category, super.key});

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getCategoryColor(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.id:
        return Colors.blue;
      case DocumentCategory.passport:
        return Colors.green;
      case DocumentCategory.visa:
        return Colors.orange;
      case DocumentCategory.certificate:
        return Colors.purple;
      case DocumentCategory.contract:
        return Colors.red;
      case DocumentCategory.other:
        return Colors.grey;
    }
  }
}

class DocumentCard extends StatelessWidget {
  final Document document;
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
          document.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            DocumentCategoryBadge(category: document.category),
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
                    color:
                        document.expiresInDays <= 30
                            ? Colors.orange
                            : Colors.green,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder:
              (context) => [
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

    switch (document.category) {
      case DocumentCategory.id:
        icon = Icons.badge;
        color = Colors.blue;
        break;
      case DocumentCategory.passport:
        icon = Icons.card_travel;
        color = Colors.green;
        break;
      case DocumentCategory.visa:
        icon = Icons.assignment;
        color = Colors.orange;
        break;
      case DocumentCategory.certificate:
        icon = Icons.description;
        color = Colors.purple;
        break;
      case DocumentCategory.contract:
        icon = Icons.note_add;
        color = Colors.red;
        break;
      case DocumentCategory.other:
        icon = Icons.file_present;
        color = Colors.grey;
        break;
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
