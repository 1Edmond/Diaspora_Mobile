import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A simple shimmering block used as a loading placeholder.
/// Kept dependency-free (no shimmer package) to match the project's
/// existing habit of using `flutter_animate` for all motion.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF232323) : const Color(0xFFE9EBEE);
    final highlight = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFF6F7F9);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: base, borderRadius: borderRadius),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: highlight);
  }
}

/// Skeleton placeholder matching the 2-column ListingCard grid, so the
/// loading state keeps the same layout as the real content (no jump).
class ListingGridSkeleton extends StatelessWidget {
  final int itemCount;

  const ListingGridSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const _ListingCardSkeleton(),
    );
  }
}

class _ListingCardSkeleton extends StatelessWidget {
  const _ListingCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: ShimmerBox(height: double.infinity, borderRadius: BorderRadius.zero),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ShimmerBox(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 60, height: 10, borderRadius: BorderRadius.circular(6)),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 80, height: 16, borderRadius: BorderRadius.circular(4)),
                  const Spacer(),
                  Row(
                    children: [
                      const ShimmerBox(width: 28, height: 28, borderRadius: BorderRadius.all(Radius.circular(14))),
                      const SizedBox(width: 8),
                      Expanded(child: ShimmerBox(width: double.infinity, height: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}