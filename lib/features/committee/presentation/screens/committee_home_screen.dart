import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../controllers/committee_notifiers.dart';

class CommitteeHomeScreen extends ConsumerWidget {
  const CommitteeHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final committeesAsync = ref.watch(committeesProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: committeesAsync.when(
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (error, stack) => Center(child: Text('Erreur: $error')),
                    data:
                        (committees) =>
                            committees.isEmpty
                                ? Center(
                                  child: Text(
                                    'Aucun comité disponible',
                                    style: TextStyle(
                                      color: AppColors.getTextSecondary(context),
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  padding: const EdgeInsets.all(20),
                                  itemCount: committees.length,
                                  itemBuilder: (context, index) {
                                    final committee = committees[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 24,
                                      ),
                                      child: NeumorphicContainer(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        committee.name,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppColors.getTextMain(context),
                                                        ),
                                                      ),
                                                    ),
                                                    _buildStatusChip(
                                                      committee.status ==
                                                          'ACTIVE',
                                                      context,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  committee.description,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        AppColors.getTextSecondary(context),
                                                    height: 1.4,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Row(
                                                  children: [
                                                    _buildQuickAction(
                                                      context,
                                                      Icons
                                                          .people_outline_rounded,
                                                      'Membres',
                                                      '/committee/${committee.id}/members',
                                                    ),
                                                    const SizedBox(width: 12),
                                                    _buildQuickAction(
                                                      context,
                                                      Icons.event_note_rounded,
                                                      'Meetings',
                                                      '/committee/${committee.id}/meetings',
                                                    ),
                                                    const SizedBox(width: 12),
                                                    _buildQuickAction(
                                                      context,
                                                      Icons
                                                          .lightbulb_outline_rounded,
                                                      'Idées',
                                                      '/committee/${committee.id}/proposals',
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                          .animate()
                                          .fadeIn(delay: (index * 100).ms)
                                          .slideY(begin: 0.1),
                                    );
                                  },
                                ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: -100,
      left: -100,
      child: Container(
        width: 350,
        height: 350,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent.withValues(alpha: 0.03),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return GlassContainer(
      borderRadius: 0,
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.getTextMain(context),
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Text(
            'Vos Comités',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextMain(context),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildStatusChip(bool isActive, BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      borderRadius: 12,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.accent : Colors.grey,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Actif' : 'Pause',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.accent : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return Expanded(
      child: NeumorphicContainer(
        height: 48,
        borderRadius: 12,
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextMain(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
