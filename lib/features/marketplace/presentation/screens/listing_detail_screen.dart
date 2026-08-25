import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/availability_slot_model.dart';
import '../controllers/marketplace_providers.dart';
import '../widgets/availability_widget.dart';
import '../widgets/review_widget.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  final _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listingDetailProvider(widget.listingId).notifier).load(widget.listingId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showTitle = _scrollController.offset > 200;
    if (showTitle != _showAppBarTitle) {
      setState(() => _showAppBarTitle = showTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingDetailProvider(widget.listingId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.isLoading && state.listing == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final listing = state.listing;
    if (listing == null && state.error != null) {
      return _buildErrorScreen(state);
    }

    if (listing == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(listing, state),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(listing),
                  const SizedBox(height: 20),
                  _buildDescriptionSection(listing),
                  const SizedBox(height: 24),
                  _buildAvailabilitySection(listing),
                  const SizedBox(height: 24),
                  _buildProviderSection(listing),
                  const SizedBox(height: 24),
                  _buildReviewsSection(state),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleFavorite,
        icon: Icon(state.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
        label: Text(state.isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris'),
        backgroundColor: state.isFavorite ? Colors.red : AppColors.primary,
        foregroundColor: Colors.white,
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSliverAppBar(ListingModel listing, ListingDetailState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          onPressed: () => context.pop(),
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
              state.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: state.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ).animate(target: state.isFavorite ? 1 : 0).scale(duration: 200.ms, curve: Curves.easeOutBack),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Hero(
          tag: 'listing-image-${widget.listingId}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              listing.imageUrls.isNotEmpty
                  ? Image.network(
                      listing.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
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

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.storefront_outlined, size: 80, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildHeaderSection(ListingModel listing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  listing.categoryName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: listing.isAvailableNow ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      listing.isAvailableNow ? Icons.check_circle_rounded : Icons.schedule_rounded,
                      size: 14,
                      color: listing.isAvailableNow ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      listing.isAvailableNow ? 'Disponible' : 'Indisponible',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: listing.isAvailableNow ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          Row(
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
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                    ),
                  ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${listing.city ?? ''}${listing.city != null && listing.country != null ? ', ' : ''}${listing.country ?? ''}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildDescriptionSection(ListingModel listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: 12),
        Text(
          listing.description,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey[700],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildAvailabilitySection(ListingModel listing) {
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
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showFullAvailability(listing, context),
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

  Widget _buildProviderSection(ListingModel listing) {
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
              listing.providerName.isNotEmpty ? listing.providerName[0].toUpperCase() : 'P',
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
                  listing.providerName.isNotEmpty ? listing.providerName : 'Prestataire',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: Colors.amber[600]),
                    const SizedBox(width: 4),
                    Text(
                      listing.averageRating.toStringAsFixed(1),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.amber[700]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${listing.reviewCount} avis • ${listing.viewCount} vues',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (listing.contactInfo != null && listing.contactInfo!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.contact_phone_rounded, size: 14, color: Colors.grey[600]),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection(ListingDetailState state) {
    final reviewsAsync = ref.watch(reviewsProvider(widget.listingId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Avis (${state.listing?.reviewCount ?? 0})',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAllReviews(),
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              label: const Text('Voir tous'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: 12),
        reviewsAsync.when(
          data: (result) {
            if (result.items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text('Aucun avis pour le moment', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: () => _showWriteReview(),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Écrire un avis'),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 800.ms);
            },
            return Column(
              children: result.items.take(3).map((review) => ReviewWidget(review: review)).toList(),
            ).animate().fadeIn(duration: 400.ms, delay: 800.ms).slideY(begin: 0.1, end: 0);
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('Erreur: $e', style: TextStyle(color: Colors.red))),
          ),
        );
      ],
    );
  }

  Widget _buildBottomBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: 900.ms).slideY(begin: 0.2, end: 0),
    );
  }

  void _toggleFavorite() {
    ref.read(listingDetailProvider(widget.listingId).notifier).toggleFavorite();
  }

  void _contactProvider() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ouverture du chat...')),
    );
  }

  void _requestService() {
    context.push('/marketplace/request/${widget.listingId}');
  }

  void _showFullAvailability(ListingModel listing, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Disponibilités complètes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AvailabilityWidget(slots: listing.availabilitySlots, isAvailableNow: listing.isAvailableNow),
                ),
              ),
            ],
          ),
        ),
      );
    },
  }

  void _showAllReviews() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Écran tous les avis - TODO')));
  }

  void _showWriteReview() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Écrire un avis - TODO')));
  }

  Widget _buildErrorScreen(ListingDetailState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Erreur', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(state.error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.read(listingDetailProvider(widget.listingId).notifier).load(widget.listingId),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
  }
}