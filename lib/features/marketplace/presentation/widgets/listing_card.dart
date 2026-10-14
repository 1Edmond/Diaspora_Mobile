import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/listing_summary_model.dart';

class ListingCard extends StatelessWidget {
  final ListingSummaryModel listing;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const ListingCard({
    super.key,
    required this.listing,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
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
                            ),
                            const SizedBox(width: 8),
                            _buildFavoriteButton(context),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildCategoryBadge(),
                        const SizedBox(height: 8),
                        _buildPriceRow(context),
                        const Spacer(),
                        _buildFooter(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get formattedPrice {
    if (listing.isTravelListing) {
      final p = listing.pricePerKg ?? listing.price;
      if (p != null) {
        final formatted = p.toStringAsFixed(p == p.toInt() ? 0 : 2);
        return '$formatted ${listing.currency ?? "XOF"}/kg';
      }
    }
    return listing.price != null
        ? '${listing.price!.toStringAsFixed(listing.price! == listing.price!.toInt() ? 0 : 2)} ${listing.currency ?? "XOF"}'
        : 'Prix sur demande';
  }

  Color getPriceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.amber[300]!
        : AppColors.primary;
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: listing.thumbnailUrl != null && listing.thumbnailUrl!.isNotEmpty
                ? Image.network(
                    listing.thumbnailUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                  )
                : _buildPlaceholder(context),
          ),
        ),
        if (listing.distanceKm != null)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded, size: 12, color: Colors.white),
                  const SizedBox(width: 3),
                  Text(
                    listing.distanceKm! < 1
                        ? '${(listing.distanceKm! * 1000).round()} m'
                        : '${listing.distanceKm!.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (listing.isTravelListing) {
      final depFlag = listing.departureCountryFlag.isNotEmpty ? listing.departureCountryFlag : '🌍';
      final arrFlag = listing.arrivalCountryFlag.isNotEmpty ? listing.arrivalCountryFlag : '🌍';

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [const Color(0xFFE0E7FF), const Color(0xFFC7D2FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(depFlag, style: const TextStyle(fontSize: 26)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.flight_takeoff_rounded, size: 20, color: Color(0xFF4338CA)),
                  ),
                  Text(arrFlag, style: const TextStyle(fontSize: 26)),
                ],
              ),
              if (listing.departureCity != null || listing.arrivalCity != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${listing.departureCity ?? ""} ➔ ${listing.arrivalCity ?? ""}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4338CA)),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Container(
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.storefront_outlined,
          size: 48,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    if (listing.isTravelListing) {
      final depFlag = listing.departureCountryFlag;
      final arrFlag = listing.arrivalCountryFlag;
      final remaining = listing.remainingKg ?? listing.capacityKg;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF4338CA).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (depFlag.isNotEmpty && arrFlag.isNotEmpty) ...[
              Text('$depFlag ➔ $arrFlag', style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
            ],
            if (remaining != null) ...[
              const Icon(Icons.luggage_rounded, size: 12, color: Color(0xFF4338CA)),
              const SizedBox(width: 3),
              Text(
                '${remaining.toStringAsFixed(remaining == remaining.toInt() ? 0 : 1)} kg dispo',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4338CA),
                ),
              ),
            ] else ...[
              const Text(
                'Trajet de transport',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4338CA),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        listing.categoryName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          formattedPrice,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.amber[300] : AppColors.primary,
          ),
        ),
        if (listing.distanceKm != null) ...[
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 3),
              Text(
                listing.distanceKm! < 1
                    ? '${(listing.distanceKm! * 1000).round()} m'
                    : '${listing.distanceKm!.toStringAsFixed(1)} km',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            listing.providerName.isNotEmpty ? listing.providerName[0].toUpperCase() : 'P',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  listing.providerName.isNotEmpty ? listing.providerName : 'Prestataire',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ),
              if (listing.providerIsVerified) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: Color(0xFF0033A0),
                ),
              ],
            ],
          ),
        ),
        Row(
          children: [
            Icon(Icons.star_rounded, size: 14, color: Colors.amber[600]),
            const SizedBox(width: 3),
            Text(
              listing.averageRating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 3),
            Text(
              '(${listing.reviewCount})',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }
}