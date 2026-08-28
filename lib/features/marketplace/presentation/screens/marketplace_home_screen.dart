import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../controllers/marketplace_providers.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/listing_card.dart';
import '../widgets/skeleton_loader.dart';

class MarketplaceHomeScreen extends ConsumerStatefulWidget {
  const MarketplaceHomeScreen({super.key});

  @override
  ConsumerState<MarketplaceHomeScreen> createState() =>
      _MarketplaceHomeScreenState();
}

enum _ExplorerMode { annonces, services }

class _MarketplaceHomeScreenState extends ConsumerState<MarketplaceHomeScreen> {
  // Two separate controllers so switching tabs never clears what the user
  // typed in the other tab — each mode keeps its own search text.
  final TextEditingController _annoncesSearchController = TextEditingController();
  final TextEditingController _servicesSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  _ExplorerMode _mode = _ExplorerMode.annonces;

  TextEditingController get _searchController =>
      _mode == _ExplorerMode.annonces ? _annoncesSearchController : _servicesSearchController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetch();
    });
  }

  @override
  void dispose() {
    _annoncesSearchController.dispose();
    _servicesSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  void _fetch({bool refresh = false}) {
    if (_mode == _ExplorerMode.annonces) {
      ref.read(marketplaceProvider.notifier).fetch(refresh: refresh);
    } else {
      ref.read(servicesProvider.notifier).fetch(refresh: refresh);
    }
  }

  void _loadMore() {
    if (_mode == _ExplorerMode.annonces) {
      ref.read(marketplaceProvider.notifier).loadNextPage();
    } else {
      ref.read(servicesProvider.notifier).loadNextPage();
    }
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }

  void _toggleFavorite(String listingId) {
    ref.read(marketplaceProvider.notifier).toggleFavorite(listingId);
  }

  void _setMode(_ExplorerMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
    _fetch(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final favoriteIds = ref.watch(favoriteIdsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (state, hasActiveFilters) = _mode == _ExplorerMode.annonces
        ? (ref.watch(marketplaceProvider), ref.watch(marketplaceProvider).hasActiveFilters)
        : (ref.watch(servicesProvider), ref.watch(servicesProvider).hasActiveFilters);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => _fetch(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(isDark),
            SliverToBoxAdapter(child: _buildModeSelector(isDark)),
            SliverToBoxAdapter(child: _buildSearchBar(isDark, state)),
            if (hasActiveFilters)
              SliverToBoxAdapter(child: _buildFilterChips(state)),
            _buildListings(state, favoriteIds, isDark),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/marketplace/create'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Publier'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 70,
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
        title: Text(
          'Marketplace',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w800,
            fontSize: 26,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: _openFilters,
            icon: Icon(
              Icons.tune_rounded,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              size: 26,
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildModeSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ModeTab(
                label: 'Annonces',
                icon: Icons.storefront_outlined,
                isSelected: _mode == _ExplorerMode.annonces,
                onTap: () => _setMode(_ExplorerMode.annonces),
                isDark: isDark,
              ),
            ),
            Expanded(
              child: _ModeTab(
                label: 'Services',
                icon: Icons.handyman_rounded,
                isSelected: _mode == _ExplorerMode.services,
                onTap: () => _setMode(_ExplorerMode.services),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildSearchBar(bool isDark, dynamic state) {
    final searchQuery = _mode == _ExplorerMode.annonces
        ? (state as MarketplaceState).searchQuery
        : (state as ServicesState).searchQuery;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: TextField(
        controller: _searchController,
        onSubmitted: (query) {
          if (_mode == _ExplorerMode.annonces) {
            ref.read(marketplaceProvider.notifier).setSearchQuery(query);
          } else {
            ref.read(servicesProvider.notifier).setSearchQuery(query);
          }
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: _mode == _ExplorerMode.annonces
              ? 'Rechercher des annonces...'
              : 'Rechercher des services...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? Colors.white54 : Colors.grey[500],
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    if (_mode == _ExplorerMode.annonces) {
                      ref.read(marketplaceProvider.notifier).setSearchQuery('');
                    } else {
                      ref.read(servicesProvider.notifier).setSearchQuery('');
                    }
                  },
                  icon: Icon(
                    Icons.clear_rounded,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                )
              : null,
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFilterChips(dynamic state) {
    final chips = <Widget>[];

    if (_mode == _ExplorerMode.annonces) {
      final s = state as MarketplaceState;
      if (s.selectedCategoryId != null) {
        chips.add(_FilterChip(
          label: 'Catégorie',
          onRemove: () => ref.read(marketplaceProvider.notifier).setCategoryId(null),
        ));
      }
      if (s.minPrice != null || s.maxPrice != null) {
        String label;
        if (s.minPrice != null && s.maxPrice != null) {
          label = '${s.minPrice!.toInt()} - ${s.maxPrice!.toInt()} XOF';
        } else if (s.minPrice != null) {
          label = 'Min ${s.minPrice!.toInt()} XOF';
        } else {
          label = 'Max ${s.maxPrice!.toInt()} XOF';
        }
        chips.add(_FilterChip(
          label: label,
          onRemove: () => ref.read(marketplaceProvider.notifier).setPriceRange(null, null),
        ));
      }
      if (s.city != null || s.country != null) {
        final place = [s.city, s.country].where((e) => e != null && e.isNotEmpty).join(', ');
        chips.add(_FilterChip(
          label: place,
          onRemove: () => ref.read(marketplaceProvider.notifier).setLocation(null, null),
        ));
      }
      if (s.availableNow) {
        chips.add(_FilterChip(
          label: 'Dispo maintenant',
          onRemove: () => ref.read(marketplaceProvider.notifier).setAvailableNow(false),
        ));
      }
    } else {
      final s = state as ServicesState;
      if (s.selectedCategory != null) {
        chips.add(_FilterChip(
          label: 'Catégorie: ${s.selectedCategory!.name}',
          onRemove: () => ref.read(servicesProvider.notifier).setCategory(null),
        ));
      }
      if (s.selectedPriceType != null) {
        chips.add(_FilterChip(
          label: 'Prix: ${s.selectedPriceType!.name}',
          onRemove: () => ref.read(servicesProvider.notifier).setPriceType(null),
        ));
      }
      if (s.selectedScope != null) {
        chips.add(_FilterChip(
          label: 'Portée: ${s.selectedScope!.name}',
          onRemove: () => ref.read(servicesProvider.notifier).setScope(null),
        ));
      }
      if (s.city != null || s.country != null) {
        final place = [s.city, s.country].where((e) => e != null && e.isNotEmpty).join(', ');
        chips.add(_FilterChip(
          label: place,
          onRemove: () => ref.read(servicesProvider.notifier).setLocation(null, null),
        ));
      }
      if (s.availableNow) {
        chips.add(_FilterChip(
          label: 'Dispo maintenant',
          onRemove: () => ref.read(servicesProvider.notifier).setAvailableNow(false),
        ));
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...chips,
          ActionChip(
            label: const Text('Tout effacer'),
            avatar: Icon(Icons.clear_all_rounded, size: 16, color: Colors.red[400]),
            onPressed: () {
              if (_mode == _ExplorerMode.annonces) {
                ref.read(marketplaceProvider.notifier).clearFilters();
              } else {
                ref.read(servicesProvider.notifier).clearFilters();
              }
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildListings(dynamic state, Set<String> favoriteIds, bool isDark) {
    final items = _mode == _ExplorerMode.annonces
        ? (state as MarketplaceState).items
        : (state as ServicesState).items;
    final isLoading = _mode == _ExplorerMode.annonces
        ? (state as MarketplaceState).isLoading
        : (state as ServicesState).isLoading;
    final error = _mode == _ExplorerMode.annonces
        ? (state as MarketplaceState).error
        : (state as ServicesState).error;
    final hasNext = _mode == _ExplorerMode.annonces
        ? (state as MarketplaceState).hasNext
        : (state as ServicesState).hasNext;

    if (isLoading && items.isEmpty) {
      // Skeleton grid instead of a bare spinner: keeps the same 2-column
      // layout as the real content so nothing jumps once data arrives,
      // and reads as "loading content" rather than "app is stuck".
      return const SliverToBoxAdapter(child: ListingGridSkeleton());
    }

    if (error != null && items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _errorView(isDark, error!),
      );
    }

    if (items.isEmpty) {
      return SliverFillRemaining(hasScrollBody: false, child: _emptyView());
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final listing = items[index];
            final card = ListingCard(
              listing: listing,
              isFavorite: favoriteIds.contains(listing.id),
              onTap: () => context.push('/marketplace/${listing.id}'),
              onFavoriteToggle: () => _toggleFavorite(listing.id),
            );
            if (index >= items.length - 1 && hasNext) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
            }
            return card
                .animate()
                .fadeIn(
                  duration: 350.ms,
                  delay: Duration(milliseconds: (index % 8) * 40),
                )
                .slideY(begin: 0.15, end: 0);
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _errorView(bool isDark, String message) {
    return Center(
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
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _fetch(refresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.2, end: 0),
    );
  }

  Widget _emptyView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _mode == _ExplorerMode.annonces
                  ? Icons.storefront_outlined
                  : Icons.handyman_rounded,
              size: 80,
              color: isDark ? Colors.white24 : Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              _mode == _ExplorerMode.annonces
                  ? 'Aucune annonce trouvée'
                  : 'Aucun service trouvé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _mode == _ExplorerMode.annonces
                  ? 'Essayez de modifier vos filtres\nou publiez la première annonce !'
                  : 'Essayez de modifier vos filtres\nou publiez le premier service !',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.2, end: 0),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.grey[600]),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.grey[600]),
              ),
            ),
          ],
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