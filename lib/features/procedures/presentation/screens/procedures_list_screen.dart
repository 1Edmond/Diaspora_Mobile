import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../controllers/procedures_notifier.dart';

class ProceduresListScreen extends ConsumerWidget {
  const ProceduresListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(proceduresProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: state.when(
                    data:
                        (items) => ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final p = items[index];
                            return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: InkWell(
                                    onTap:
                                        () =>
                                            context.push('/procedures/${p.id}'),
                                    borderRadius: BorderRadius.circular(20),
                                    child: NeumorphicContainer(
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                width: 60,
                                                height: 60,
                                                child: CircularProgressIndicator(
                                                  value: p.userProgress / 100,
                                                  strokeWidth: 6,
                                                  backgroundColor: AppColors
                                                      .primary
                                                      .withValues(alpha: 0.1),
                                                  valueColor:
                                                      const AlwaysStoppedAnimation<
                                                        Color
                                                      >(AppColors.accent),
                                                ),
                                              ),
                                              Text(
                                                '${p.userProgress}%',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  p.title,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    color: AppColors.getTextMain(context),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  p.description,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color:
                                                        AppColors.getTextSecondary(context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 16,
                                            color: AppColors.getTextSecondary(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: (index * 100).ms)
                                .slideX(begin: 0.1);
                          },
                        ),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Erreur: $e')),
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
      bottom: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.04),
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
            'Mes Démarches',
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
}
