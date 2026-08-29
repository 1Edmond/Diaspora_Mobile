import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/home_back_button.dart';
import '../../data/models/service_request_model.dart';
import '../../domain/entities/enums.dart';
import '../controllers/marketplace_providers.dart';

/// Lists the current user's sent service requests ("réservations" made as a
/// customer). Wired to `serviceRequestsProvider` which loads via
/// `getMySentRequests`.
class MyRequestsScreen extends ConsumerStatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  ConsumerState<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends ConsumerState<MyRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceRequestsProvider.notifier).loadSent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceRequestsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const HomeBackButton(),
        title: Text(
          'Mes demandes',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: _buildBody(state, isDark),
    );
  }

  Widget _buildBody(ServiceRequestsState state, bool isDark) {
    if (state.isLoadingSent && state.sentItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.sentItems.isEmpty) {
      return Center(
        child: FilledButton.icon(
          onPressed: () => ref.read(serviceRequestsProvider.notifier).loadSent(),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Réessayer'),
        ),
      );
    }
    if (state.sentItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined,
                size: 72, color: isDark ? Colors.white24 : Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Aucune demande',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos demandes de service apparaîtront ici.',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => ref.read(serviceRequestsProvider.notifier).loadSent(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: state.sentItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _requestCard(state.sentItems[index], isDark)
                .animate()
                .fadeIn(duration: 300.ms, delay: Duration(milliseconds: (index % 6) * 50))
                .slideX(begin: 0.08, end: 0),
      ),
    );
  }

  Widget _requestCard(ServiceRequestModel request, bool isDark) {
    final status = request.status;
    final statusLabel = _statusLabel(status);
    final statusColor = _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.listingTitle,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.providerName.trim().isNotEmpty
                ? request.providerName
                : 'Prestataire',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          if (request.message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              request.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.grey[700]),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                _formatDate(request.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const Spacer(),
              if (request.status == ServiceRequestStatus.cancelled)
                TextButton(
                  onPressed: () => ref
                      .read(serviceRequestsProvider.notifier)
                      .cancelRequest(request.id, ''),
                  child: const Text('Annuler', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(ServiceRequestStatus s) {
    switch (s) {
      case ServiceRequestStatus.pending:
        return 'En attente';
      case ServiceRequestStatus.accepted:
        return 'Acceptée';
      case ServiceRequestStatus.declined:
        return 'Refusée';
      case ServiceRequestStatus.completed:
        return 'Complétée';
      case ServiceRequestStatus.cancelled:
        return 'Annulée';
    }
  }

  Color _statusColor(ServiceRequestStatus s) {
    switch (s) {
      case ServiceRequestStatus.pending:
        return Colors.orange;
      case ServiceRequestStatus.accepted:
        return Colors.blue;
      case ServiceRequestStatus.declined:
        return Colors.red;
      case ServiceRequestStatus.completed:
        return Colors.green;
      case ServiceRequestStatus.cancelled:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime d) {
    final l = d.toLocal();
    return '${l.day}/${l.month}/${l.year}';
  }
}