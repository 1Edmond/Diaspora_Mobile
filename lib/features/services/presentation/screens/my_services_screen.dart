import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../controllers/services_notifier.dart';
import '../widgets/service_card.dart';

class MyServicesScreen extends ConsumerWidget {
  const MyServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Mes services',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextMain(context),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.add_rounded, color: AppColors.primary),
                  onPressed: () => context.push('/services/create'),
                ),
              ],
            ),
            state.when(
              data: (items) {
                final mine = items.where((s) => s.providerId == 'u_mock').toList();
                if (mine.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.dashboard_customize_rounded, size: 48, color: AppColors.getTextSecondary(context)),
                          const SizedBox(height: 12),
                          Text('Aucun service publié', style: TextStyle(color: AppColors.getTextSecondary(context))),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => context.push('/services/create'),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Publier un service'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final s = mine[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ServiceCard(
                                service: s,
                                onTap: () => context.push('/services/${s.id}', extra: {'isOwn': true}),
                              ),
                              Positioned(
                                top: -6,
                                right: 12,
                                child: _StatusBadge(status: s.status),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: mine.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, s) => SliverFillRemaining(child: Center(child: Text('Erreur: $e'))),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      'ACTIVE' => (AppColors.accent, 'Actif'),
      'PENDING' => (AppColors.warning, 'En attente'),
      'APPROVED' => (AppColors.primary, 'Approuvé'),
      'REJECTED' => (Colors.red, 'Rejeté'),
      'INACTIVE' => (Colors.grey, 'Inactif'),
      _ => (AppColors.getTextSecondary(context), status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: config.$1.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        config.$2,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: config.$1),
      ),
    );
  }
}
