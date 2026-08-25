import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/listing_summary_model.dart';
import '../controllers/marketplace_providers.dart';
import '../widgets/listing_card.dart';
import '../widgets/filter_bottom_sheet.dart';

class MarketplaceHomeScreen extends ConsumerStatefulWidget {
  const MarketplaceHomeScreen({super.key});

  @override
  ConsumerState<MarketplaceHomeScreen> createState() => _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends ConsumerState<MarketplaceHomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketplaceProvider.notifier).fetch(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showFab = _scrollController.offset < 100;
    if (showFab != _showFab) {
      setState(() => _showFab = showFab);
    }
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(marketplaceProvider.notifier).loadNextPage();
    }
  }

  void _onSearchChanged(String query) {
    ref.read(marketplaceProvider.notifier).setSearchQuery(query);
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(context, isDark),
          _buildSearchBar(context, isDark),
          if (state.hasActiveFilters) _buildActiveFiltersChips(context, isDark),
          _buildListingsGrid(context, isDark, state),
        ],
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/marketplace/create'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Publier'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'Marketplace',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w800,
            fontSize: 28,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () => _openFilters(),
            icon: Icon(
              Icons.tune_rounded,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              size: 26,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Rechercher des services...',
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey[500],
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark ? Colors.white54 : Colors.grey[500],
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(marketplaceProvider.notifier).setSearchQuery('');
                    },
                    icon: Icon(
                      Icons.clear_rounded,
                      color: isDark ? Colors.white54 : Colors.grey[500],
                    ),
                  )
                : null,
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey[200]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey[200]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildActiveFiltersChips(BuildContext context, bool isDark) {
    final state = ref.watch(marketplaceProvider);
    final chips = <Widget>[];

    if (state.selectedCategoryId != null) {
      chips.add(_FilterChip(
        label: 'Catégorie',
        onRemove: () => ref.read(marketplaceProvider.notifier).setCategoryId(null),
      ));
    }
    if (state.minPrice != null || state.maxPrice != null) {
      final label = state.minPrice != null && state.maxPrice != null
          ? '${state.minPrice!.toInt()}-${state.maxPrice!.toInt()} XOF'
          : state.minPrice != null
              ? '+${state.minPrice!.toInt()} XOF'
              : '-${state.maxPrice!.toInt()} XOF';
      chips.add(_FilterChip(
        label: 'Prix: $label',
        onRemove: () => ref.read(marketplaceProvider.notifier).setPriceRange(null, null),
      ));
    }
    if (state.city != null || state.country != null) {
      chips.add(_FilterChip(
        label: 'Lieu: ${state.city ?? ''}${state.city != null && state.country != null ? ', ' : ''}${state.country ?? ''}',
        onRemove: () => ref.read(marketplaceProvider.notifier).setLocation(null, null),
      ));
    }
    if (state.availableNow) {
      chips.add(_FilterChip(
        label: 'Dispo maintenant',
        onRemove: () => ref.read(marketplaceProvider.notifier).setAvailableNow(false),
      ));
    }
    if (state.searchQuery.isNotEmpty) {
      chips.add(_FilterChip(
        label: 'Recherche: "${state.searchQuery}"',
        onRemove: () => ref.read(marketplaceProvider.notifier).setSearchQuery(''),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...chips,
            TextButton.icon(
              onPressed: () => ref.read(marketplaceProvider.notifier).clearFilters(),
              icon: Icon(Icons.clear_all_rounded, size: 16, color: AppColors.primary),
              label: Text('Tout effacer', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
    );
  }

  Widget _buildListingsGrid(BuildContext context, bool isDark, MarketplaceState state) {
    if (state.isLoading && state.items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Chargement des annonces...',
                style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
              ),
            ],
          ),
        );
      ).animate().fadeIn();
    }

    if (state.error != null && state.items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: isDark ? Colors.white38 : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => ref.read(marketplaceProvider.notifier).fetch(refresh: true),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        );
      ).animate().fadeIn().slideY(begin: 0.2, end: 0);

    if (state.items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 80,
                  color: isDark ? Colors.white24 : Colors.grey[300],
                ),
                const SizedBox(height: 20),
                Text(
                  'Aucune annonce trouvée',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Essayez de modifier vos filtres\nou créez la première annonce !',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.push('/marketplace/create'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Publier une annonce'),
                ),
              ],
            ),
          ),
        );
      ).animate().fadeIn().slideY(begin: 0.2, end: 0);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final listing = state.items[index];
            return ListingCard(
              listing: listing,
              isFavorite: ref.read(favoriteIdsProvider).contains(listing.id),
              onTap: () => context.push('/marketplace/${listing.id}'),
              onFavoriteToggle: () => ref.read(marketplaceProvider.notifier).toggleFavorite(listing.id),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: (index * 50).ms.clamp(0.ms, 500.ms))
                .slideY(begin: 0.2, end: 0)
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
          },
          childCount: state.items.length,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}