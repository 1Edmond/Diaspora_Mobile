import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../../chat/domain/repositories/chat_repository.dart';
import '../../data/models/listing_model.dart';
import '../controllers/marketplace_providers.dart';
import '../widgets/availability_widget.dart';
import '../widgets/review_widget.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/write_review_sheet.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(listingDetailProvider(widget.listingId).notifier)
          .load(widget.listingId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    ref
        .read(listingDetailProvider(widget.listingId).notifier)
        .toggleFavorite();
  }

  Future<void> _contactProvider() async {
    final listing = ref.read(listingDetailProvider(widget.listingId)).listing;
    if (listing == null) return;

    // Show a spinner dialog while the conversation is created/resolved,
    // instead of the previous placeholder SnackBar that did nothing.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final chatRepository = GetIt.instance<IChatRepository>();
      // createConversation is idempotent server-side for direct messages,
      // so calling it again on a repeat visit just returns the existing
      // thread rather than creating a duplicate.
      final conversation = await chatRepository.createConversation(
        listing.providerName,
        [listing.providerId],
      );

      if (!mounted) return;
      context.pop(); // close the loading dialog
      context.push('/chat/${conversation.id}');
    } catch (e) {
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir la conversation : $e')),
      );
    }
  }

  void _requestService() {
    context.push('/marketplace/request/${widget.listingId}');
  }

  void _writeReview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WriteReviewSheet(listingId: widget.listingId),
    );
  }

  void _showAllReviews() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tous les avis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      TextButton.icon(
                        onPressed: _writeReview,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Écrire'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final reviewsAsync = ref.watch(reviewsProvider(widget.listingId));
                      return reviewsAsync.when(
                        data: (result) => ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: result.items.map((r) => ReviewWidget(review: r)).toList(),
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Erreur : $e')),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingDetailProvider(widget.listingId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.isLoading && state.listing == null) {
      return _loadingScreen(isDark);
    }

    final listing = state.listing;
    if (listing == null) {
      if (state.error != null) return _errorScreen(state);
      return _loadingScreen(isDark);
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(listing, state.isFavorite),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(listing),
                  const SizedBox(height: 20),
                  _buildDescription(listing),
                  const SizedBox(height: 24),
                  _buildAvailability(listing),
                  const SizedBox(height: 24),
                  _buildProviderCard(listing),
                  const SizedBox(height: 24),
                  _buildReviewsHeader(state),
                  const SizedBox(height: 12),
                  ReviewsListWidget(
                    listingId: widget.listingId,
                    onWriteReview: _writeReview,
                    onShowAll: _showAllReviews,
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _loadingScreen(bool isDark) {
    // Skeleton matching the real layout (hero image + text blocks) instead
    // of a bare centered spinner, so the transition into loaded content
    // doesn't feel like a jump cut.
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: double.infinity, height: 220, borderRadius: BorderRadius.circular(20)),
              const SizedBox(height: 20),
              ShimmerBox(width: 100, height: 20, borderRadius: BorderRadius.circular(8)),
              const SizedBox(height: 12),
              const ShimmerBox(width: double.infinity, height: 26),
              const SizedBox(height: 20),
              const ShimmerBox(width: double.infinity, height: 60),
              const SizedBox(height: 20),
              ShimmerBox(width: double.infinity, height: 80, borderRadius: BorderRadius.circular(16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorScreen(ListingDetailState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text('Erreur de chargement',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                state.error ?? 'Erreur inconnue',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref
                    .read(listingDetailProvider(widget.listingId).notifier)
                    .load(widget.listingId),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ListingModel listing, bool isFavorite) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Hero(
          tag: 'listing-image-${widget.listingId}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildHeroImage(listing),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                    stops: [0.6, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage(ListingModel listing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (listing.imageUrls.isNotEmpty) {
      return Image.network(
        listing.imageUrls.first,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(isDark),
      );
    }
    return _imagePlaceholder(isDark);
  }

  Widget _imagePlaceholder(bool isDark) {
    return Container(
      color: isDark ? Colors.grey[800] : Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.storefront_outlined,
          size: 80,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildHeader(ListingModel listing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _categoryBadge(listing.categoryName),
            const Spacer(),
            _availabilityBadge(listing.isAvailableNow),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 12),
        Text(
          listing.title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        _ratingRow(listing),
        const SizedBox(height: 8),
        _locationRow(listing),
      ],
    );
  }

  Widget _categoryBadge(String categoryName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        categoryName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _availabilityBadge(bool isAvailableNow) {
    final color = isAvailableNow ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailableNow ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isAvailableNow ? 'Disponible' : 'Indisponible',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingRow(ListingModel listing) {
    return Row(
      children: [
        Icon(Icons.star_rounded, size: 20, color: Colors.amber[600]),
        const SizedBox(width: 6),
        Text(
          listing.averageRating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.amber[700],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(${listing.reviewCount} avis)',
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
        ),
        const Spacer(),
        if (listing.distanceKm != null)
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                listing.distanceKm! < 1
                    ? '${(listing.distanceKm! * 1000).round()} m'
                    : '${listing.distanceKm!.toStringAsFixed(1)} km',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _locationRow(ListingModel listing) {
    final location = [
      listing.city,
      listing.country,
    ].where((e) => e != null && e.isNotEmpty).join(', ');
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            location.isEmpty ? 'Localisation non précisée' : location,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ListingModel listing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: 12),
        Text(
          listing.description,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildAvailability(ListingModel listing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Disponibilités',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showFullAvailability(listing),
              icon: const Icon(Icons.expand_more_rounded, size: 18),
              label: const Text('Voir tout'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: 12),
        AvailabilityWidget(
          slots: listing.availabilitySlots,
          isAvailableNow: listing.isAvailableNow,
        ),
      ],
    );
  }

  Widget _buildProviderCard(ListingModel listing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final providerName =
        listing.providerName.trim().isNotEmpty ? listing.providerName : 'Prestataire';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              providerName[0].toUpperCase(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  providerName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: Colors.amber[600]),
                    const SizedBox(width: 4),
                    Text(
                      listing.averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${listing.reviewCount} avis • ${listing.viewCount} vues',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (listing.contactInfo != null &&
                    listing.contactInfo!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.contact_phone_rounded,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          listing.contactInfo!,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildReviewsHeader(ListingDetailState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Avis (${state.listing?.reviewCount ?? 0})',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        TextButton.icon(
          onPressed: _showAllReviews,
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          label: const Text('Voir tous'),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _contactProvider,
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Contacter'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _requestService,
                icon: const Icon(Icons.local_offer_rounded),
                label: const Text('Demander un service'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 900.ms).slideY(begin: 0.2, end: 0);
  }

  void _showFullAvailability(ListingModel listing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scrollController) {
          final sheetIsDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              color: sheetIsDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Disponibilités complètes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AvailabilityWidget(
                      slots: listing.availabilitySlots,
                      isAvailableNow: listing.isAvailableNow,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ReviewsListWidget extends ConsumerWidget {
  final String listingId;
  final VoidCallback onWriteReview;
  final VoidCallback onShowAll;

  const ReviewsListWidget({
    super.key,
    required this.listingId,
    required this.onWriteReview,
    required this.onShowAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsProvider(listingId));

    return reviewsAsync.when(
      data: (result) {
        if (result.items.isEmpty) {
          return _emptyState(onWriteReview);
        }
        return Column(
          children: result.items
              .take(3)
              .map((r) => ReviewWidget(review: r))
              .toList(),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 800.ms)
            .slideY(begin: 0.1, end: 0);
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Erreur lors du chargement des avis',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(VoidCallback onWriteReview) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Aucun avis pour le moment',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onWriteReview,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Écrire un avis'),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 800.ms);
  }
}