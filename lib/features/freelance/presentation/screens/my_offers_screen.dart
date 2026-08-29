import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/job_posting_model.dart';
import '../../domain/entities/enums.dart';
import '../controllers/freelance_providers_ext.dart';
import '../freelance_labels.dart';

class MyOffersScreen extends ConsumerStatefulWidget {
  const MyOffersScreen({super.key});

  @override
  ConsumerState<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends ConsumerState<MyOffersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myJobPostingsProvider.notifier).load();
    });
  }

  Future<void> _showActions(
      JobPostingSummaryModel posting) async {
    final notifier = ref.read(myJobPostingsProvider.notifier);
    final actions = _actionsFor(posting.status);
    if (actions.isEmpty) return;

    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                posting.title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            ...actions.map(
              (a) => ListTile(
                leading: Icon(a.icon, color: a.color),
                title: Text(a.label),
                onTap: () => Navigator.pop(c, a.key),
              ),
            ),
          ],
        ),
      ),
    );

    if (chosen == null) return;

    bool ok = false;
    switch (chosen) {
      case 'publish':
        ok = await notifier.publish(posting.id);
        break;
      case 'close-registration':
        ok = await notifier.closeRegistration(posting.id);
        break;
      case 'start':
        ok = await notifier.start(posting.id);
        break;
      case 'complete':
        ok = await notifier.complete(posting.id);
        break;
      case 'cancel':
        ok = await notifier.cancel(posting.id);
        break;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Action effectuée.' : 'Action impossible.'),
      ),
    );
  }

  List<_Action> _actionsFor(JobPostingStatus status) {
    switch (status) {
      case JobPostingStatus.draft:
        return [_Action('publish', 'Publier', Icons.publish_rounded, Colors.green)];
      case JobPostingStatus.open:
        return [
          _Action('close-registration', 'Clore les inscriptions',
              Icons.lock_rounded, Colors.orange),
          _Action('cancel', 'Annuler', Icons.cancel_rounded, Colors.red),
        ];
      case JobPostingStatus.registrationClosed:
        return [
          _Action('start', 'Démarrer', Icons.play_arrow_rounded, Colors.blue),
          _Action('cancel', 'Annuler', Icons.cancel_rounded, Colors.red),
        ];
      case JobPostingStatus.inProgress:
        return [
          _Action('complete', 'Terminer', Icons.check_circle_rounded, Colors.purple),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myJobPostingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mes offres',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/freelance/create'),
          ),
        ],
      ),
      body: state.isLoading && state.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
              ? const Center(child: Text('Aucune offre.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final p = state.items[index];
                    final color = jobPostingStatusColor(p.status);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  p.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  jobPostingStatusLabel(p.status),
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: color),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${p.acceptedCount}/${p.capacity} places',
                            style:
                                TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context
                                      .push('/freelance/${p.id}/applications'),
                                  child: const Text('Candidatures'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (_actionsFor(p.status).isNotEmpty)
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () => _showActions(p),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                    ),
                                    child: const Text('Action'),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn();
                  },
                ),
    );
  }
}

class _Action {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const _Action(this.key, this.label, this.icon, this.color);
}