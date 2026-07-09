import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/document_category.dart';
import '../../presentation/controllers/document_providers.dart';
import '../../presentation/widgets/document_card.dart';

class DocumentsListScreen extends ConsumerStatefulWidget {
  const DocumentsListScreen({super.key});

  @override
  ConsumerState<DocumentsListScreen> createState() =>
      _DocumentsListScreenState();
}

class _DocumentsListScreenState extends ConsumerState<DocumentsListScreen> {
  String? _selectedCategory;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For now, using a hardcoded userId - in production, get from auth provider
    const userId = 'u_test';

    final provider =
        _searchQuery.isNotEmpty
            ? documentSearchProvider((userId: userId, query: _searchQuery))
            : _selectedCategory != null
            ? documentsByCategoryProvider((
              userId: userId,
              category: DocumentCategory.fromString(_selectedCategory!),
            ))
            : documentsByUserProvider(userId);

    final documentsAsync = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes documents'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher des documents...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          // Category filter
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildCategoryChip('Tous', null),
                ...DocumentCategory.values.map(
                  (category) =>
                      _buildCategoryChip(category.label, category.value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Documents list
          Expanded(
            child: documentsAsync.when(
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
                          'Erreur lors du chargement',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
              data: (documents) {
                if (documents.isEmpty) {
                  return DocumentEmptyState(
                    onAddDocument: () {
                      context.push('/documents/upload');
                    },
                  );
                }

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    return DocumentCard(
                      document: document,
                      onTap: () {
                        context.push('/documents/${document.id}');
                      },
                      onDelete: () {
                        _showDeleteConfirmation(context, document.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/documents/upload');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String documentId) {
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
                      .deleteDocument(documentId);
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document supprimé')),
                  );
                  setState(() {});
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
