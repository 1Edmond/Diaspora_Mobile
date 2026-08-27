import 'package:diaspora_app/features/marketplace/data/models/listing_summary_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../controllers/marketplace_providers.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  int? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myListingsProvider.notifier).fetch(refresh: true);
    });
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'annonce ?'),
        content:
            const Text('Cette action est définitive et ne peut pas être annulée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(myListingsProvider.notifier).deleteListing(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myListingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mes annonces',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_rounded,
                size: 28, color: AppColors.primary),
            onPressed: () => context.push('/marketplace/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          _statusTabs(isDark, state),
          Expanded(child: _buildList(state, isDark)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/marketplace/create'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Publier'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _statusTabs(bool isDark, MyListingsState state) {
    final tabs = [
      (null, 'Tous'),
      (1, 'Approuvés'),
      (0, 'En attente'),
      (2, 'Rejetés'),
      (3, 'Suspendus'),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (status, label) = tabs[index];
          final selected = _statusFilter == status;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => setState(() => _statusFilter = status),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? AppColors.primary
                  : (isDark ? Colors.white60 : Colors.grey[600]),
            ),
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: selected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildList(MyListingsState state, bool isDark) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final items = state.items;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront_outlined,
                  size: 72, color: isDark ? Colors.white24 : Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Aucune annonce',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Publiez votre premier service\npour toucher la communauté.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
              ),
            ],
          ),
        ),
      ).animate().fadeIn();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          ref.read(myListingsProvider.notifier).fetch(refresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final listing = items[index];
          return _listingRow(listing, isDark)
              .animate()
              .fadeIn(duration: 300.ms, delay: Duration(milliseconds: (index % 6) * 50))
              .slideX(begin: 0.08, end: 0);
        },
      ),
    );
  }

  Widget _listingRow(ListingSummaryModel listing, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 64,
              child: listing.thumbnailUrl != null &&
                      listing.thumbnailUrl!.isNotEmpty
                  ? Image.network(
                      listing.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _thumbPlaceholder(isDark),
                    )
                  : _thumbPlaceholder(isDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        size: 14, color: Colors.amber[600]),
                    const SizedBox(width: 3),
                    Text(
                      listing.averageRating.toStringAsFixed(1),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${listing.reviewCount} avis',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      listing.price != null
                          ? '${listing.price!.toStringAsFixed(0)} ${listing.currency ?? "XOF"}'
                          : 'Prix sur demande',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.amber[300] : AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    _statusBadge(listing.status),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (action) {
              switch (action) {
                case 'edit':
                  context.push('/marketplace/${listing.id}/edit');
                  break;
                case 'delete':
                  _confirmDelete(listing.id);
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Modifier'),
                ]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _thumbPlaceholder(bool isDark) {
    return Container(
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      child: Icon(Icons.storefront_outlined,
          size: 28, color: isDark ? Colors.grey[600] : Colors.grey[400]),
    );
  }

  Widget _statusBadge(int status) {
    final config = switch (status) {
      0 => (Colors.orange, 'En attente'),
      1 => (Colors.green, 'Approuvé'),
      2 => (Colors.red, 'Rejeté'),
      3 => (Colors.grey, 'Suspendu'),
      _ => (Colors.grey, 'Inconnu'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: config.$1.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        config.$2,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: config.$1,
        ),
      ),
    );
  }
}
