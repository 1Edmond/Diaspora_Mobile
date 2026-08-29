import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/enums.dart';
import '../controllers/freelance_providers_ext.dart';

class ReputationScreen extends ConsumerWidget {
  final String subjectId;
  final ReputationRole role;

  const ReputationScreen({
    super.key,
    required this.subjectId,
    required this.role,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repAsync = ref.watch(reputationProvider((subjectId, role.index)));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Réputation',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: repAsync.when(
        data: (rep) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: 80, color: Colors.amber[600]),
              const SizedBox(height: 12),
              Text(
                rep.hasReviews ? rep.averageRating.toStringAsFixed(1) : '—',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                rep.hasReviews
                    ? '${rep.totalRatings} avis'
                    : 'Pas encore d\'avis',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              if (rep.hasReviews) ...[
                _subscore('Ponctualité', rep.averagePunctuality),
                _subscore('Qualité', rep.averageQuality),
                _subscore('Communication', rep.averageCommunication),
                const SizedBox(height: 16),
                Text('${rep.totalJobsCompleted} missions complétées',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
      ),
    );
  }

  Widget _subscore(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          for (int i = 0; i < 5; i++)
            Icon(
              i < value.round() ? Icons.star_rounded : Icons.star_border_rounded,
              size: 18,
              color: Colors.amber[600],
            ),
          const SizedBox(width: 8),
          Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}