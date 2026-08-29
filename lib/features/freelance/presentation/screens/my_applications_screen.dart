import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/job_application_model.dart';
import '../../domain/entities/enums.dart';
import '../controllers/freelance_providers.dart';
import '../freelance_labels.dart';

class MyApplicationsScreen extends ConsumerStatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  ConsumerState<MyApplicationsScreen> createState() =>
      _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myApplicationsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myApplicationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mes candidatures',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: _buildBody(state, isDark),
    );
  }

  Widget _buildBody(MyApplicationsState state, bool isDark) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined,
                size: 72, color: isDark ? Colors.white24 : Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Aucune candidature',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final app = state.items[index];
        return _ApplicationTile(application: app);
      },
    );
  }
}

class _ApplicationTile extends ConsumerWidget {
  final JobApplicationModel application;
  const _ApplicationTile({required this.application});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              Expanded(
                child: Text(
                  application.jobPostingTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  jobApplicationStatusLabel(application.status),
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
          if (application.message != null &&
              application.message!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              application.message!,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 8),
          if (application.status == JobApplicationStatus.pending ||
              application.status == JobApplicationStatus.accepted)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await ref
                      .read(myApplicationsProvider.notifier)
                      .withdraw(application.id);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Retirer'),
              ),
            ),
        ],
      ),
    ).animate().fadeIn();
  }
}