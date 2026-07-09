import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../controllers/services_notifier.dart';
import '../widgets/service_card.dart';

class ServicesHomeScreen extends ConsumerStatefulWidget {
  const ServicesHomeScreen({super.key});

  @override
  ConsumerState<ServicesHomeScreen> createState() => _ServicesHomeScreenState();
}

class _ServicesHomeScreenState extends ConsumerState<ServicesHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(servicesProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                _buildProcedureSummary(),
                _buildSectionHeader('Explorez nos Services'),
                state.when(
                  data:
                      (items) => SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ServiceCard(
                                    service: items[i],
                                    onTap:
                                        () => context.push(
                                          '/services/${items[i].id}',
                                        ),
                                  )
                                  .animate()
                                  .fadeIn(delay: (i * 100).ms)
                                  .slideY(begin: 0.1),
                            ),
                            childCount: items.length,
                          ),
                        ),
                      ),
                  loading:
                      () => const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  error:
                      (e, s) => SliverFillRemaining(
                        child: Center(child: Text('Erreur: $e')),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: NeumorphicContainer(
        width: 60,
        height: 60,
        borderRadius: 30,
        color: AppColors.primary,
        child: IconButton(
          icon: const Icon(
            Icons.add_task_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () => context.push('/services/create'),
        ),
      ).animate().scale(delay: 500.ms),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: -150,
      left: -100,
      child: Container(
        width: 350,
        height: 350,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.04),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'E-Services',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded, color: AppColors.textMain),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProcedureSummary() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Procédures en cours',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip('Juridique', 'En cours', AppColors.primary),
                  _buildStatusChip('Visa', 'Validé', AppColors.accent),
                ],
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1),
      ),
    );
  }

  Widget _buildStatusChip(String label, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
