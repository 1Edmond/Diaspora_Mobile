import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../data/models/step_model.dart';
import '../controllers/procedures_notifier.dart';
import '../../data/models/procedure_model.dart';

class ProcedureDetailScreen extends ConsumerWidget {
  final String procedureId;

  const ProcedureDetailScreen({required this.procedureId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(proceduresProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: state.when(
        data: (items) {
          final procedure = items.firstWhere(
            (element) => element.id == procedureId,
            orElse: () => items.first,
          );
          return _buildContent(context, ref, procedure);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ProcedureModel procedure) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isOverdue = procedure.deadline != null && procedure.deadline!.isBefore(DateTime.now());

    return Stack(
      children: [
        _buildBackground(),
        SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context, procedure.title),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressCard(context, procedure, dateFormat, isOverdue),
                      const SizedBox(height: 32),
                      Text(
                        'Étapes de la procédure',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextMain(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStepsList(context, ref, procedure),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: -100,
      left: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondary.withValues(alpha: 0.04),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String title) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.getTextMain(context),
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.getTextMain(context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, ProcedureModel p, DateFormat dateFormat, bool isOverdue) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: p.userProgress / 100,
                      strokeWidth: 10,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        p.userProgress >= 100 ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    '${p.userProgress}%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextMain(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statut Actuel',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.userProgress >= 100 ? 'Terminé' : 'En cours de validation',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      p.description,
                      style: TextStyle(
                        color: AppColors.getTextMain(context),
                        fontSize: 14,
                      ),
                    ),
                    if (p.deadline != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: isOverdue ? Colors.red : AppColors.warning),
                          const SizedBox(width: 4),
                          Text(
                            '${isOverdue ? 'Dépassée' : 'Limite'} : ${dateFormat.format(p.deadline!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? Colors.red : AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildStepsList(BuildContext context, WidgetRef ref, ProcedureModel procedure) {
    if (procedure.steps.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Aucune étape définie pour cette procédure.',
            style: TextStyle(color: AppColors.getTextSecondary(context)),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < procedure.steps.length; i++) ...[
          _StepTile(
            step: procedure.steps[i],
            index: i,
            procedureId: procedure.id,
            ref: ref,
          ),
          if (i < procedure.steps.length - 1)
            Padding(
              padding: const EdgeInsets.only(left: 11),
              child: SizedBox(
                height: 32,
                child: Container(
                  width: 2,
                  color: procedure.steps[i].isCompleted ? AppColors.accent : Colors.grey.shade300,
                ),
              ),
            ),
        ],
      ],
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _StepTile extends ConsumerStatefulWidget {
  final StepModel step;
  final int index;
  final String procedureId;
  final WidgetRef ref;

  const _StepTile({
    required this.step,
    required this.index,
    required this.procedureId,
    required this.ref,
  });

  @override
  ConsumerState<_StepTile> createState() => _StepTileState();
}

class _StepTileState extends ConsumerState<_StepTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final step = widget.step;

    return Dismissible(
      key: ValueKey(step.id),
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: AppColors.warning,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.cancel_outlined, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        widget.ref.read(proceduresProvider.notifier).toggleStep(widget.procedureId, step.id);
        return false;
      },
      direction: step.isCompleted ? DismissDirection.endToStart : DismissDirection.startToEnd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: GestureDetector(
              onTap: () {
                widget.ref.read(proceduresProvider.notifier).toggleStep(widget.procedureId, step.id);
              },
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isCompleted ? AppColors.accent : Colors.grey.shade300,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: step.isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : const Icon(Icons.circle, size: 8, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => setState(() => _expanded = !_expanded),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: step.isCompleted ? AppColors.accent : AppColors.getTextMain(context),
                                    decoration: step.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  step.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.getTextSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                            color: AppColors.getTextSecondary(context),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.topCenter,
                    firstChild: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          if (step.comment != null && step.comment!.isNotEmpty) ...[
                            _InfoRow(icon: Icons.chat_bubble_outline_rounded, label: 'Commentaire', value: step.comment!),
                            const SizedBox(height: 8),
                          ],
                          if (step.price != null && step.price!.isNotEmpty) ...[
                            _InfoRow(icon: Icons.monetization_on_outlined, label: 'Coût', value: '${step.price} FCFA'),
                            const SizedBox(height: 8),
                          ],
                          if (step.address != null && step.address!.isNotEmpty) ...[
                            _InfoRow(icon: Icons.location_on_outlined, label: 'Adresse', value: step.address!),
                          ],
                        ],
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                    crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    firstCurve: Curves.easeInOut,
                    secondCurve: Curves.easeInOut,
                    sizeCurve: Curves.easeInOut,
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: AppColors.getTextSecondary(context)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.getTextSecondary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.getTextMain(context),
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
