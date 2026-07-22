import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../data/models/procedure_model.dart';
import '../../data/models/location_model.dart';
import '../../data/models/day_schedule_model.dart';
import '../controllers/procedures_notifier.dart';

class ProcedureDetailScreen extends ConsumerWidget {
  final String procedureId;

  const ProcedureDetailScreen({required this.procedureId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(proceduresProvider);

    if (state.isLoading && state.items.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: Text('Erreur: ${state.error}')),
      );
    }

    final matched = state.items.where((e) => e.id == procedureId).toList();
    if (matched.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: Text('Procédure introuvable')),
      );
    }
    final procedure = matched.first;

    final dependencies = _resolveDependencies(state.items, procedure);
    final isCompleted = state.completedProcedureIds.contains(procedure.id);

    return _buildContent(context, ref, procedure, dependencies, isCompleted);
  }

  List<ProcedureModel> _resolveDependencies(List<ProcedureModel> allItems, ProcedureModel proc) {
    return allItems.where((p) => proc.dependencyIds.contains(p.id)).toList();
  }

Widget _buildContent(BuildContext context, WidgetRef ref, ProcedureModel procedure, List<ProcedureModel> dependencies, bool isCompleted) {
    final isOverdue = procedure.deadline != null && procedure.deadline!.isBefore(DateTime.now());
    final state = ref.read(proceduresProvider);
    final completedIds = state.completedProcedureIds;
    final isStarted = state.startedProcedureIds.contains(procedure.id);
    final isBlocked = _isBlockedByDependencies(procedure, completedIds);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(context, procedure.title),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(context, ref, procedure, isOverdue, isCompleted, isStarted, isBlocked),
                      if (dependencies.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildDependencyTimeline(context, dependencies, completedIds),
                      ],
                      const SizedBox(height: 24),
                      if (procedure.locations.isNotEmpty) ...[
                        Text(
                          'Lieux de la procédure',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextMain(context),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildLocationsStrip(context, procedure.locations),
                      ],
                      if (procedure.locations.isEmpty) ...[
                        GlassContainer(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'Aucun lieu défini pour cette procédure.',
                              style: TextStyle(color: AppColors.getTextSecondary(context)),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
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
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, WidgetRef ref, ProcedureModel p, bool isOverdue, bool isCompleted, bool isStarted, bool isBlocked) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildProfileTypeBadge(p.profileType),
              const SizedBox(width: 8),
              if (!p.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Inactive',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.red),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            p.description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(context, Icons.attach_money_rounded, p.costAmount > 0 ? '${p.costAmount} ${p.costCurrency}' : 'Gratuit'),
              const SizedBox(width: 16),
              _buildInfoChip(context, Icons.schedule_rounded, '~${p.estimatedDurationDays} jours'),
            ],
          ),
          if (p.deadline != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: isOverdue ? Colors.red : AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  '${isOverdue ? 'Délai dépassé' : 'Échéance'} : ${_formatDeadline(p.deadline!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverdue ? Colors.red : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildProcedureToggle(context, ref, p.id, isCompleted, isStarted, isBlocked)),
            ],
          ),
          if (p.requiredDocumentTypeIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildRequiredDocuments(context, p.requiredDocumentTypeIds),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildProcedureToggle(BuildContext context, WidgetRef ref, String procedureId, bool isCompleted, bool isStarted, bool isBlocked) {
    if (isBlocked && !isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_rounded, size: 18, color: AppColors.warning),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Nécessite une procédure préalable non terminée',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent, width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 20, color: AppColors.accent),
            SizedBox(width: 10),
            Text(
              'Procédure terminée',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accent),
            ),
          ],
        ),
      );
    }

    if (isStarted) {
      return InkWell(
        onTap: () => ref.read(proceduresProvider.notifier).completeProcedure(procedureId),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.task_alt_rounded, size: 20, color: AppColors.secondary),
              SizedBox(width: 10),
              Text(
                'Marquer comme terminée',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => ref.read(proceduresProvider.notifier).startProcedure(procedureId),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded, size: 20, color: AppColors.primary),
            SizedBox(width: 10),
            Text(
              'Commencer',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  bool _isBlockedByDependencies(ProcedureModel p, Set<String> completedIds) {
    if (p.dependencyIds.isEmpty) return false;
    return p.dependencyIds.any((depId) => !completedIds.contains(depId));
  }

  Widget _buildProfileTypeBadge(String profileType) {
    final isInternal = profileType == 'Internal';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isInternal ? AppColors.primary.withValues(alpha: 0.12) : AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isInternal ? Icons.business_rounded : Icons.public_rounded,
            size: 14,
            color: isInternal ? AppColors.primary : AppColors.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            isInternal ? 'Interne' : 'Externe',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isInternal ? AppColors.primary : AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.getTextSecondary(context)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.getTextSecondary(context))),
      ],
    );
  }

  Widget _buildRequiredDocuments(BuildContext context, List<String> docIds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents requis',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.getTextSecondary(context)),
        ),
        const SizedBox(height: 8),
        ...List.generate(docIds.length, (i) => Padding(
          padding: EdgeInsets.only(bottom: i < docIds.length - 1 ? 8 : 0),
          child: Row(
            children: [
              const Icon(Icons.description_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(_docLabel(docIds[i]), style: const TextStyle(fontSize: 13))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDependencyTimeline(BuildContext context, List<ProcedureModel> dependencies, Set<String> completedIds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Procédures préalables',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMain(context),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(dependencies.length, (i) {
          final dep = dependencies[i];
          final isLast = i == dependencies.length - 1;
          final depCompleted = completedIds.contains(dep.id);
          return _buildDependencyStep(context, dep, isLast, i, depCompleted);
        }),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildDependencyStep(BuildContext context, ProcedureModel dep, bool isLast, int index, bool depCompleted) {
    return SizedBox(
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: depCompleted
                        ? AppColors.accent.withValues(alpha: 0.18)
                        : AppColors.primary.withValues(alpha: 0.12),
                    border: Border.all(
                      color: depCompleted ? AppColors.accent.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: depCompleted
                        ? const Icon(Icons.check_rounded, size: 16, color: AppColors.accent)
                        : Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: depCompleted ? AppColors.accent.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => context.push('/procedures/${dep.id}'),
              borderRadius: BorderRadius.circular(12),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dep.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: depCompleted ? AppColors.getTextSecondary(context) : AppColors.getTextMain(context),
                              decoration: depCompleted ? TextDecoration.lineThrough : null,
                              decorationColor: AppColors.accent.withValues(alpha: 0.4),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            depCompleted ? 'Terminée' : dep.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 11,
                              color: depCompleted ? AppColors.accent : dep.isActive ? AppColors.primary : Colors.red.shade300,
                              fontWeight: depCompleted ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (depCompleted)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.check_circle_rounded, size: 18, color: AppColors.accent),
                      )
                    else
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsStrip(BuildContext context, List<LocationModel> locations) {
    final cardWidth = (MediaQuery.of(context).size.width * 0.75).clamp(240.0, 320.0);
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 20),
        itemCount: locations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SizedBox(
          width: cardWidth,
          child: _buildLocationStripCard(context, locations[index], index),
        ),
      ),
    );
  }

  Widget _buildLocationStripCard(BuildContext context, LocationModel loc, int index) {
    final address = '${loc.street}, ${loc.postalCode} ${loc.city}';
    return GlassContainer(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                  child: Center(
                    child: Text('${index + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(loc.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.getTextMain(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildLocationActionDetail(context, Icons.location_on_outlined, address, onTap: () => _openMaps(loc)),
            Row(
              children: [
                if (loc.phoneNumber != null) ...[
                  Expanded(
                    child: _buildCompactAction(context, Icons.phone_outlined, loc.phoneNumber!, onTap: () => _openPhone(loc.phoneNumber!)),
                  ),
                ],
                if (loc.phoneNumber != null && loc.website != null) const SizedBox(width: 12),
                if (loc.website != null) ...[
                  Flexible(
                    child: _buildCompactAction(context, Icons.language_rounded, loc.website!, onTap: () => _openUrl(loc.website!)),
                  ),
                ],
                if (loc.phoneNumber == null && loc.website == null) const Spacer(),
              ],
            ),
            if (loc.schedule.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 6),
              _buildScheduleStrip(context, loc.schedule),
            ],
          ],
        ),
      );
  }

  Widget _buildCompactAction(BuildContext context, IconData icon, String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: onTap != null ? AppColors.primary : Colors.grey),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: onTap != null ? AppColors.primary : AppColors.getTextSecondary(context),
                decoration: onTap != null ? TextDecoration.underline : null,
                decorationColor: AppColors.primary.withValues(alpha: 0.25),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationActionDetail(BuildContext context, IconData icon, String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: onTap != null ? AppColors.primary : AppColors.getTextSecondary(context)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: onTap != null ? AppColors.primary : AppColors.getTextMain(context),
                  decoration: onTap != null ? TextDecoration.underline : null,
                  decorationColor: AppColors.primary.withValues(alpha: 0.3),
                ),
                softWrap: true,
              ),
            ),
            if (onTap != null) const Padding(
              padding: EdgeInsets.only(left: 4, top: 1),
              child: Icon(Icons.open_in_new_rounded, size: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleStrip(BuildContext context, List<DayScheduleModel> schedule) {
    final todayIndex = DateTime.now().weekday - 1;
    final frenchDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Horaires', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.getTextSecondary(context))),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 50),
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: schedule.length,
            separatorBuilder: (_, __) => const SizedBox(width: 5),
            itemBuilder: (context, index) {
              final s = schedule[index];
              final isToday = index == todayIndex;
              return Container(
                width: 44,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: isToday ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(frenchDays[index], style: TextStyle(fontSize: 9, fontWeight: isToday ? FontWeight.bold : FontWeight.w500, color: isToday ? AppColors.primary : AppColors.getTextSecondary(context))),
                    if (s.isClosed)
                      Text('Fermé', style: TextStyle(fontSize: 7, color: Colors.red.shade300))
                    else ...[
                      Text(_formatTime(s.openTime), style: TextStyle(fontSize: 8, color: AppColors.getTextSecondary(context))),
                      Text(_formatTime(s.closeTime), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: AppColors.getTextMain(context))),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openMaps(LocationModel loc) async {
    final encoded = Uri.encodeComponent('${loc.street}, ${loc.city}, ${loc.state} ${loc.postalCode}, ${loc.country}');
    final uri = Uri.parse('https://maps.google.com/maps?q=$encoded');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded'), mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  Future<void> _openPhone(String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(RegExp(r'[^\d+]'), '')}');
    try { await launchUrl(uri, mode: LaunchMode.externalApplication); } catch (_) {}
  }

  Future<void> _openUrl(String url) async {
    var uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) uri = Uri.parse('https://$url');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {}
  }

  String _formatDeadline(DateTime dt) {
    final months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(String? time) {
    if (time == null) return '--';
    final parts = time.split(':');
    return parts.length < 2 ? time : '${parts[0]}h${parts[1]}';
  }

  String _docLabel(String docId) {
    switch (docId) {
      case 'doc_passport': return 'Passeport';
      case 'doc_visa': return 'Visa';
      case 'doc_diploma': return 'Diplôme';
      case 'doc_transcript': return 'Relevé de notes';
      case 'doc_student_card': return 'Carte étudiante';
      case 'doc_residence_permit': return 'Titre de séjour';
      case 'doc_bank_document': return 'Document bancaire';
      case 'doc_insurance': return 'Attestation d\'assurance';
      case 'doc_medical': return 'Certificat médical';
      case 'doc_contract': return 'Contrat';
      default: return docId.replaceAll('doc_', '').replaceAll('_', ' ');
    }
  }
}