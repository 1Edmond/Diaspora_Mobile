import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../controllers/procedures_notifier.dart';
import '../../data/models/procedure_model.dart';

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
                  child: _buildBody(context, ref, state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ProceduresState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(proceduresProvider.notifier).fetch(),
      child: _buildContent(context, ref, state),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ProceduresState state) {
    if (state.error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 300,
            child: Center(child: Text('Erreur: ${state.error}')),
          ),
        ],
      );
    }
    if (state.items.isEmpty && !state.isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 300,
            child: Center(
              child: Text(
                'Aucune procédure disponible',
                style: TextStyle(color: AppColors.getTextSecondary(context)),
              ),
            ),
          ),
        ],
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            state.hasNext &&
            !state.isLoading) {
          ref.read(proceduresProvider.notifier).loadNextPage();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: state.items.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final p = state.items[index];
          final isCompleted = state.completedProcedureIds.contains(p.id);
          final isStarted = state.startedProcedureIds.contains(p.id);
          final hasBlockedDeps = _hasUnfulfilledDependencies(p, state.completedProcedureIds);
          return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: InkWell(
                  onTap: () => context.push('/procedures/${p.id}'),
                  borderRadius: BorderRadius.circular(20),
                  child: NeumorphicContainer(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? AppColors.accent.withValues(alpha: 0.15)
                                : hasBlockedDeps
                                    ? AppColors.warning.withValues(alpha: 0.12)
                                    : isStarted
                                        ? AppColors.secondary.withValues(alpha: 0.15)
                                        : AppColors.primary.withValues(alpha: 0.1),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check_rounded, size: 28, color: AppColors.accent)
                                : hasBlockedDeps
                                    ? const Icon(Icons.lock_rounded, size: 22, color: AppColors.warning)
                                    : isStarted
                                        ? const Icon(Icons.play_circle_outline_rounded, size: 24, color: AppColors.secondary)
                                        : const Icon(Icons.article_outlined, size: 24, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: AppColors.getTextMain(context),
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  decorationColor: AppColors.accent.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.getTextSecondary(context),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _buildProfileTypeBadge(context, p.profileType),
                                  const SizedBox(width: 8),
                                  if (p.costAmount > 0)
                                    Text(
                                      '${p.costAmount} ${p.costCurrency}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  const Spacer(),
                                  Text(
                                    isCompleted
                                        ? 'Terminé'
                                        : hasBlockedDeps
                                            ? 'Prérequis'
                                            : isStarted
                                                ? 'Démarré'
                                                : 'Non démarré',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isCompleted
                                          ? AppColors.accent
                                          : hasBlockedDeps
                                              ? AppColors.warning
                                              : isStarted
                                                  ? AppColors.secondary
                                                  : AppColors.primary,
                                    ),
                                  ),
                                  if (p.deadline != null) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 12,
                                      color: p.deadline!.isBefore(DateTime.now()) ? Colors.red : AppColors.getTextSecondary(context),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      p.deadline!.isBefore(DateTime.now()) ? 'Dépassée' : 'J-${p.deadline!.difference(DateTime.now()).inDays}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: p.deadline!.isBefore(DateTime.now()) ? Colors.red : AppColors.getTextSecondary(context),
                                        fontWeight: p.deadline!.isBefore(DateTime.now()) ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ],
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
    );
  }

  Widget _buildProfileTypeBadge(BuildContext context, String profileType) {
    final isInternal = profileType == 'Internal';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isInternal ? AppColors.primary.withValues(alpha: 0.1) : AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isInternal ? 'Interne' : 'Externe',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isInternal ? AppColors.primary : AppColors.secondary,
        ),
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

  bool _hasUnfulfilledDependencies(ProcedureModel p, Set<String> completedIds) {
    if (p.dependencyIds.isEmpty) return false;
    return p.dependencyIds.any((depId) => !completedIds.contains(depId));
  }
}