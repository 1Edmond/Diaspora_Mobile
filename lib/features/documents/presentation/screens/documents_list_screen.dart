import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/diaspora_app_bar.dart';
import '../controllers/document_providers.dart';
import '../widgets/document_card.dart';
import '../../data/models/document_type_model.dart';

class DocumentsListScreen extends ConsumerStatefulWidget {
  const DocumentsListScreen({super.key});

  @override
  ConsumerState<DocumentsListScreen> createState() =>
      _DocumentsListScreenState();
}

class _DocumentsListScreenState extends ConsumerState<DocumentsListScreen> {
  final _scrollController = ScrollController();
  var _searchExpanded = false;
  final _searchFocusNode = FocusNode();
  final _searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(documentsListProvider.notifier).fetch();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(documentsListProvider.notifier).loadNextPage();
    }
  }

  void _toggleSearch() {
    setState(() {
      _searchExpanded = !_searchExpanded;
    });
    if (!_searchExpanded) {
      _searchFocusNode.unfocus();
      _searchTextController.clear();
      ref.read(documentsListProvider.notifier).setSearchQuery('');
    } else {
      Future.delayed(200.ms, () => _searchFocusNode.requestFocus());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentsListProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: DiasporaAppBar(title: 'Mes documents'),
            ),
            _buildSearchBar(context),
            _buildFilterAndSortBar(context, state),
            Expanded(child: _buildBody(context, state)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/documents/upload'),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _searchExpanded ? Icons.close : Icons.search,
                color: AppColors.getTextSecondary(context),
              ),
              onPressed: _toggleSearch,
            ),
            if (_searchExpanded)
              Expanded(
                child: TextField(
                      controller: _searchTextController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un document...',
                        hintStyle: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      style: TextStyle(
                        color: AppColors.getTextMain(context),
                        fontSize: 14,
                      ),
                      onChanged:
                          (v) => ref
                              .read(documentsListProvider.notifier)
                              .setSearchQuery(v),
                    )
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .slideX(
                      begin: -0.1,
                      duration: 200.ms,
                      curve: Curves.easeOut,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterAndSortBar(
    BuildContext context,
    DocumentsListState state,
  ) {
    final docTypesAsync = ref.watch(documentTypesProvider);
    final docTypes = docTypesAsync.valueOrNull ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (int i = 0; i < docTypes.length + 1; i++)
                  _buildChoiceChip(context, state, docTypes, i),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<DocumentSortField>(
            onSelected:
                (field) => ref
                    .read(documentsListProvider.notifier)
                    .setSortField(field),
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _sortIcon(state.sortField),
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    state.sortAscending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            itemBuilder:
                (context) => [
                  _sortItem(DocumentSortField.date, 'Date'),
                  _sortItem(DocumentSortField.name, 'Nom'),
                  _sortItem(DocumentSortField.status, 'Statut'),
                  _sortItem(DocumentSortField.size, 'Taille'),
                ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(
    BuildContext context,
    DocumentsListState state,
    List<DocumentTypeModel> docTypes,
    int i,
  ) {
    final isSelected =
        i == 0
            ? state.selectedDocTypeId == null
            : docTypes[i - 1].id == state.selectedDocTypeId;
    final label = i == 0 ? 'Tous' : docTypes[i - 1].name;
    final chipId = i == 0 ? null : docTypes[i - 1].id;

    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (_) {
        ref.read(documentsListProvider.notifier).setDocTypeFilter(chipId);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color:
            isSelected
                ? AppColors.primary
                : AppColors.getTextSecondary(context),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color:
            isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.getDivider(context),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  PopupMenuItem<DocumentSortField> _sortItem(
    DocumentSortField field,
    String label,
  ) {
    final state = ref.read(documentsListProvider);
    final isActive = state.sortField == field;
    return PopupMenuItem(
      value: field,
      child: Row(
        children: [
          Icon(
            _sortIcon(field),
            size: 18,
            color:
                isActive
                    ? AppColors.primary
                    : AppColors.getTextSecondary(context),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color:
                  isActive ? AppColors.primary : AppColors.getTextMain(context),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isActive)
            Icon(
              state.sortAscending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 16,
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  IconData _sortIcon(DocumentSortField field) {
    switch (field) {
      case DocumentSortField.date:
        return Icons.calendar_today_rounded;
      case DocumentSortField.name:
        return Icons.sort_by_alpha_rounded;
      case DocumentSortField.status:
        return Icons.verified_rounded;
      case DocumentSortField.size:
        return Icons.storage_rounded;
    }
  }

  Widget _buildBody(BuildContext context, DocumentsListState state) {
    final processed = state.processedItems;

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur lors du chargement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.getTextMain(context),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(documentsListProvider.notifier).fetch(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (processed.isEmpty) {
      if (state.searchQuery.isNotEmpty || state.selectedDocTypeId != null) {
        return _buildEmptyFilteredState(context);
      }
      return DocumentEmptyState(
        onAddDocument: () => context.push('/documents/upload'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(documentsListProvider.notifier).fetch(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: processed.length + (state.hasNext ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= processed.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final document = processed[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DocumentCard(
                  document: document,
                  onTap: () => context.push('/documents/${document.id}'),
                  onDelete: () => _showDeleteConfirmation(context, document.id),
                )
                .animate()
                .fadeIn(delay: (index % 10 * 50).ms, duration: 300.ms)
                .slideY(
                  begin: 0.15,
                  delay: (index % 10 * 50).ms,
                  duration: 300.ms,
                  curve: Curves.easeOut,
                ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyFilteredState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextMain(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
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
              'Êtes-vous sûr de vouloir supprimer ce document ?',
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
                  ref.read(documentsListProvider.notifier).refresh();
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
