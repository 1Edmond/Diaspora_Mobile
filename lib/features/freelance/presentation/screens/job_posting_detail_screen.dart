import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/job_posting_model.dart';
import '../../domain/entities/enums.dart';
import '../controllers/freelance_providers.dart';
import '../freelance_labels.dart';

class JobPostingDetailScreen extends ConsumerStatefulWidget {
  final String jobPostingId;
  const JobPostingDetailScreen({super.key, required this.jobPostingId});

  @override
  ConsumerState<JobPostingDetailScreen> createState() =>
      _JobPostingDetailScreenState();
}

class _JobPostingDetailScreenState
    extends ConsumerState<JobPostingDetailScreen> {
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobDetailProvider(widget.jobPostingId).notifier).load(widget.jobPostingId);
    });
  }

  Future<void> _apply(JobPostingModel posting) async {
    final controller = TextEditingController();
    final message = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ApplySheet(controller: controller),
    );
    controller.dispose();
    if (message == null) return;

    setState(() => _submitting = true);
    try {
      await ref
          .read(myApplicationsProvider.notifier)
          .apply(posting.id, message.isEmpty ? null : message);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Candidature envoyée !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de postuler : $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobDetailProvider(widget.jobPostingId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.isLoading && state.posting == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final posting = state.posting;
    if (posting == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: FilledButton.icon(
            onPressed: () => ref
                .read(jobDetailProvider(widget.jobPostingId).notifier)
                .load(widget.jobPostingId),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
          ),
        ),
      );
    }

    final canApply = posting.status == JobPostingStatus.open &&
        posting.remainingPlaces > 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          posting.title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusRow(posting),
            const SizedBox(height: 16),
            _amountRow(posting),
            const SizedBox(height: 16),
            _infoCard(posting, isDark),
            const SizedBox(height: 16),
            _section('Description', posting.description),
            if (posting.requiredSkills.isNotEmpty)
              _section('Compétences requises', posting.requiredSkills.join(' · ')),
            if (posting.requiredDocuments.isNotEmpty)
              _section('Documents requis',
                  posting.requiredDocuments.join(', ')),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(posting, canApply, isDark),
    );
  }

  Widget _statusRow(JobPostingModel p) {
    final color = jobPostingStatusColor(p.status);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            jobPostingStatusLabel(p.status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          p.categoryName,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _amountRow(JobPostingModel p) {
    return Row(
      children: [
        Icon(Icons.euro_rounded, size: 22, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          '${p.amount} ${p.currency}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          paymentTypeLabel(p.paymentType),
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const Spacer(),
        Text(
          '${p.acceptedCount}/${p.capacity} places',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _infoCard(JobPostingModel p, bool isDark) {
    final rows = <(IconData, String)>[
      (Icons.event_rounded, 'Du ${_dt(p.eventStartAt)} au ${_dt(p.eventEndAt)}'),
      (
        Icons.location_on_outlined,
        p.isRemote ? 'Télétravail' : _location(p)
      ),
      (Icons.pin_drop_outlined, 'Pointage: ${checkInMethodLabel(p.checkInMethod)}'),
      (
        Icons.payments_outlined,
        p.paymentTiming == PaymentTiming.escrowUpfront
            ? 'Paiement sécurisé (escrow)'
            : 'Paiement à la complétion'
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: rows
            .map(
              (r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(r.$1, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(r.$2,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[700])),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _section(String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(JobPostingModel p, bool canApply, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: SafeArea(
        child: FilledButton(
          onPressed: (canApply && !_submitting) ? () => _apply(p) : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  canApply ? 'Postuler' : 'Candidatures fermées',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }

  String _dt(DateTime d) {
    final l = d.toLocal();
    return '${l.day}/${l.month}/${l.year} ${l.hour}h${l.minute.toString().padLeft(2, '0')}';
  }

  String _location(JobPostingModel p) {
    return [p.city, p.country]
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');
  }
}

class _ApplySheet extends StatefulWidget {
  final TextEditingController controller;
  const _ApplySheet({required this.controller});

  @override
  State<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends State<_ApplySheet> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.grey[300],
              ),
            ),
            const Text('Postuler',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            TextField(
              controller: widget.controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Message facultatif...',
                filled: true,
                fillColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.pop(context, widget.controller.text.trim()),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Envoyer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }
}