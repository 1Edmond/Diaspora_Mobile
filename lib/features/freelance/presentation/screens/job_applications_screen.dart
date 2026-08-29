import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/job_posting_model.dart';
import '../../data/models/job_application_model.dart';
import '../../domain/entities/enums.dart';
import '../controllers/freelance_orchestrator.dart';
import '../controllers/freelance_providers.dart';
import '../controllers/freelance_providers_ext.dart';
import '../freelance_labels.dart';

class JobApplicationsScreen extends ConsumerStatefulWidget {
  final String jobPostingId;
  const JobApplicationsScreen({super.key, required this.jobPostingId});

  @override
  ConsumerState<JobApplicationsScreen> createState() =>
      _JobApplicationsScreenState();
}

class _JobApplicationsScreenState
    extends ConsumerState<JobApplicationsScreen> {
  JobPostingModel? _posting;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobDetailProvider(widget.jobPostingId).notifier).load(widget.jobPostingId);
      ref
          .read(jobApplicationsProvider(widget.jobPostingId).notifier)
          .load(widget.jobPostingId);
    });
  }

  Future<void> _accept(JobApplicationModel app) async {
    final posting = _posting;
    if (posting == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(freelanceOrchestratorProvider).acceptApplication(
            posting: posting,
            application: app,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Candidature acceptée.'), backgroundColor: Colors.green),
      );
      ref.read(jobApplicationsProvider(widget.jobPostingId).notifier).load(widget.jobPostingId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Acceptation impossible : $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject(JobApplicationModel app) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(freelanceRepositoryProvider)
          .rejectApplication(app.id, reason: null);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Candidature refusée.')),
      );
      ref.read(jobApplicationsProvider(widget.jobPostingId).notifier).load(widget.jobPostingId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Refus impossible : $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _complete(JobApplicationModel app) async {
    final posting = _posting;
    if (posting == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(freelanceOrchestratorProvider).completeApplication(
            posting: posting,
            application: app,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Mission terminée et paiement effectué.'),
            backgroundColor: Colors.green),
      );
      ref.read(jobApplicationsProvider(widget.jobPostingId).notifier).load(widget.jobPostingId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terminaison impossible : $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openChat(JobApplicationModel app) async {
    final posting = _posting;
    if (posting == null) return;
    try {
      final conversationId = await ref
          .read(freelanceOrchestratorProvider)
          .linkChatThread(posting: posting, application: app);
      if (!mounted) return;
      context.push('/chat/$conversationId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir la discussion : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final postingState = ref.watch(jobDetailProvider(widget.jobPostingId));
    _posting = postingState.posting;
    final appsState = ref.watch(jobApplicationsProvider(widget.jobPostingId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Candidatures',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: appsState.isLoading && appsState.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : appsState.items.isEmpty
              ? const Center(child: Text('Aucune candidature reçue.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appsState.items.length,
                  itemBuilder: (context, index) {
                    final app = appsState.items[index];
                    return _ApplicationCard(
                      application: app,
                      busy: _busy,
                      onAccept: () => _accept(app),
                      onReject: () => _reject(app),
                      onComplete: () => _complete(app),
                      onChat: () => _openChat(app),
                    );
                  },
                ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final JobApplicationModel application;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onComplete;
  final VoidCallback onChat;

  const _ApplicationCard({
    required this.application,
    required this.busy,
    required this.onAccept,
    required this.onReject,
    required this.onComplete,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = jobApplicationStatusColor(application.status);

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
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text(
                  application.workerName.isNotEmpty
                      ? application.workerName[0].toUpperCase()
                      : '?',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.workerName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      jobApplicationStatusLabel(application.status),
                      style: TextStyle(fontSize: 12, color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (application.message != null && application.message!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              application.message!,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: busy ? null : onChat,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text('Discussion'),
              ),
              const Spacer(),
              if (application.status == JobApplicationStatus.pending) ...[
                OutlinedButton(
                  onPressed: busy ? null : onAccept,
                  child: const Text('Accepter'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: busy ? null : onReject,
                  child: const Text('Refuser'),
                ),
              ] else if (application.status == JobApplicationStatus.accepted) ...[
                FilledButton(
                  onPressed: busy ? null : onComplete,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Terminer et payer'),
                ),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}