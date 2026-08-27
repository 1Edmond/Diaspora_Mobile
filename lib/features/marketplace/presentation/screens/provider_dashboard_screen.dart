import 'package:diaspora_app/features/marketplace/data/models/provider_stats_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../controllers/marketplace_providers.dart';

class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(providerStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mon activité',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: false,
      ),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.refresh(providerStatsProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              _heroCard(stats, isDark),
              const SizedBox(height: 16),
              _sectionTitle('Annonces', isDark),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      context: context,
                      icon: Icons.inventory_2_rounded,
                      label: 'Total',
                      value: '${stats.totalListings}',
                      color: Colors.blue,
                      delayMs: 150,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      context: context,
                      icon: Icons.check_circle_rounded,
                      label: 'Actives',
                      value: '${stats.activeListings}',
                      color: Colors.green,
                      delayMs: 200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionTitle('Demandes', isDark),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      context: context,
                      icon: Icons.inbox_rounded,
                      label: 'Reçues',
                      value: '${stats.totalRequestsReceived}',
                      color: Colors.orange,
                      delayMs: 250,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      context: context,
                      icon: Icons.done_all_rounded,
                      label: 'Complétées',
                      value: '${stats.completedRequests}',
                      color: AppColors.primary,
                      delayMs: 300,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _progressCard(stats, isDark),
              const SizedBox(height: 16),
              _sectionTitle('Réputation', isDark),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      context: context,
                      icon: Icons.star_rounded,
                      label: 'Note moyenne',
                      value: stats.averageRating.toStringAsFixed(1),
                      color: Colors.amber[700]!,
                      delayMs: 400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      context: context,
                      icon: Icons.favorite_rounded,
                      label: 'Favoris',
                      value: '${stats.totalFavorites}',
                      color: Colors.red,
                      delayMs: 450,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _revenueCard(stats, isDark),
              const SizedBox(height: 12),
              _responseTimeCard(stats, isDark),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insights_outlined, size: 56, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'Statistiques indisponibles',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Connectez-vous ou vérifiez votre connexion.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => ref.refresh(providerStatsProvider.future),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ).animate().fadeIn(),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _heroCard(ProviderStatsModel stats, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF0044CC)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: Colors.white, size: 26),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Taux d\'acceptation ${stats.acceptanceRatePercent.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Revenus complétés',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            stats.totalRevenueCompleted.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const Text(
            'XOF',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 450.ms)
        .slideY(begin: 0.15, end: 0)
        .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1));
  }

  Widget _statCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required int delayMs,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms, delay: Duration(milliseconds: delayMs))
        .slideY(begin: 0.15, end: 0);
  }

  Widget _progressCard(ProviderStatsModel stats, bool isDark) {
    final rate = (stats.acceptanceRatePercent / 100).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Demandes acceptées',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                '${stats.acceptedRequests}/${stats.totalRequestsReceived}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: rate),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor:
                    AppColors.primary.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 350.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _revenueCard(ProviderStatsModel stats, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.payments_rounded, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note moyenne globale',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${stats.averageRating.toStringAsFixed(1)} / 5 • ${stats.totalReviews} avis',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 500.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _responseTimeCard(ProviderStatsModel stats, bool isDark) {
    final hasData = stats.averageResponseTimeHours != null;
    final display = hasData
        ? stats.getFormattedAverageResponseTimeSafe()
        : 'Pas encore de données';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(Icons.timer_outlined, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Temps de réponse moyen',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  display,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 550.ms).slideY(begin: 0.15, end: 0);
  }
}

extension on ProviderStatsModel {
  String getFormattedAverageResponseTimeSafe() {
    final hours = averageResponseTimeHours!;
    if (hours < 1) return '${(hours * 60).round()} min';
    if (hours < 24) return '${hours.toStringAsFixed(1)} h';
    return '${(hours / 24).toStringAsFixed(1)} j';
  }
}
