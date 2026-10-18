import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/home_back_button.dart';
import '../../../chat/domain/repositories/chat_repository.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../data/models/service_request_model.dart';
import '../../domain/entities/enums.dart';
import '../controllers/marketplace_providers.dart';

/// Screen displaying service requests received by the current provider.
/// Allows accepting, declining (with reason), and completing service requests.
class ReceivedServiceRequestsScreen extends ConsumerStatefulWidget {
  const ReceivedServiceRequestsScreen({super.key});

  @override
  ConsumerState<ReceivedServiceRequestsScreen> createState() =>
      _ReceivedServiceRequestsScreenState();
}

class _ReceivedServiceRequestsScreenState
    extends ConsumerState<ReceivedServiceRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceRequestsProvider.notifier).loadReceived();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Demandes reçues',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.grey[600],
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'En attente'),
            Tab(text: 'En cours'),
            Tab(text: 'Terminées'),
          ],
        ),
      ),
      body: _buildBody(state, isDark),
    );
  }

  Widget _buildBody(ServiceRequestsState state, bool isDark) {
    if (state.isLoadingReceived && state.receivedItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.receivedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Erreur lors du chargement',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(serviceRequestsProvider.notifier).loadReceived(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildList(state.receivedItems, isDark),
        _buildList(
          state.receivedItems
              .where((r) => r.status == ServiceRequestStatus.pending)
              .toList(),
          isDark,
        ),
        _buildList(
          state.receivedItems
              .where((r) =>
                  r.status == ServiceRequestStatus.accepted ||
                  r.status == ServiceRequestStatus.packageHandedOver ||
                  r.status == ServiceRequestStatus.inTransit ||
                  r.status == ServiceRequestStatus.arrivedAtDestination)
              .toList(),
          isDark,
        ),
        _buildList(
          state.receivedItems
              .where(
                (r) =>
                    r.status == ServiceRequestStatus.completed ||
                    r.status == ServiceRequestStatus.delivered ||
                    r.status == ServiceRequestStatus.declined ||
                    r.status == ServiceRequestStatus.cancelled,
              )
              .toList(),
          isDark,
        ),
      ],
    );
  }

  Widget _buildList(List<ServiceRequestModel> items, bool isDark) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: isDark ? Colors.white24 : Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune demande dans cette catégorie',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          ref.read(serviceRequestsProvider.notifier).loadReceived(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = items[index];
          return _requestCard(request, isDark)
              .animate()
              .fadeIn(
                duration: 300.ms,
                delay: Duration(milliseconds: (index % 6) * 40),
              )
              .slideY(begin: 0.05, end: 0);
        },
      ),
    );
  }

  Widget _requestCard(ServiceRequestModel request, bool isDark) {
    final statusColor = _statusColor(request.status);
    final statusLabel = _statusLabel(request.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.listingTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          request.requesterName.isNotEmpty
                              ? request.requesterName
                              : 'Demandeur',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (request.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                request.message,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.grey[800],
                ),
              ),
            ),
          ],
          if (request.agreedPrice != null && request.agreedPrice! > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Prix convenu : ',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${request.agreedPrice!.toStringAsFixed(2)} ${request.agreedCurrency ?? "XOF"}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.amber[300] : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                _buildPaymentBadge(request.paymentStatus),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 13, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                _formatDate(request.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const Spacer(),
              _buildActions(request),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(PaymentStatus status) {
    String label;
    Color color;
    switch (status) {
      case PaymentStatus.held:
        label = 'Séquestre actif';
        color = Colors.blue;
        break;
      case PaymentStatus.completed:
        label = 'Fonds libérés';
        color = Colors.green;
        break;
      case PaymentStatus.processing:
        label = 'Traitement';
        color = Colors.purple;
        break;
      case PaymentStatus.pending:
        label = 'En attente paiement';
        color = Colors.orange;
        break;
      case PaymentStatus.refunded:
        label = 'Remboursé';
        color = Colors.grey;
        break;
      case PaymentStatus.failed:
        label = 'Paiement échoué';
        color = Colors.red;
        break;
      case PaymentStatus.notApplicable:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildActions(ServiceRequestModel request) {
    if (request.status == ServiceRequestStatus.pending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: () => _showDeclineDialog(request),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(60, 32),
            ),
            child: const Text('Refuser'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () async {
              try {
                await ref
                    .read(serviceRequestsProvider.notifier)
                    .acceptRequest(request.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demande acceptée')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(60, 32),
            ),
            child: const Text('Accepter'),
          ),
        ],
      );
    }

    final isParcelInProgress = request.isParcelRequest &&
        (request.status == ServiceRequestStatus.accepted ||
            request.status == ServiceRequestStatus.packageHandedOver ||
            request.status == ServiceRequestStatus.inTransit ||
            request.status == ServiceRequestStatus.arrivedAtDestination);

    if (isParcelInProgress) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _openChat(request),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
            tooltip: 'Discuter avec l\'expéditeur',
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push(
              '/marketplace/parcel/track/${request.id}?role=traveler',
              extra: request,
            ),
            icon: const Icon(Icons.local_shipping_rounded, size: 16),
            label: const Text('Gérer le colis'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(60, 32),
            ),
          ),
        ],
      );
    }

    if (request.status == ServiceRequestStatus.accepted && !request.isParcelRequest) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _openChat(request),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
            tooltip: 'Discuter avec le demandeur',
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () async {
              try {
                await ref
                    .read(serviceRequestsProvider.notifier)
                    .completeRequest(request.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Service marqué comme complété')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Terminer'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(60, 32),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _openChat(ServiceRequestModel request) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final chatRepo = GetIt.instance<IChatRepository>();
      final activeProfile = ref.read(activeProfileProvider);
      final currentUser = ref.read(authNotifierProvider).valueOrNull;
      final myProfileId = activeProfile?.id ?? currentUser?.id ?? 'me';

      final myChatId = await chatRepo.resolveChatProfileByExternal(myProfileId);
      final requesterChatId =
          await chatRepo.resolveChatProfileByExternal(request.requesterId);

      final conversation =
          await chatRepo.createDirectConversation(myChatId, requesterChatId);

      if (!mounted) return;
      context.pop();
      context.push('/chat/${conversation.id}');
    } catch (e) {
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir la discussion : $e')),
      );
    }
  }

  void _showDeclineDialog(ServiceRequestModel request) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Refuser la demande'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Veuillez indiquer le motif du refus (obligatoire) :',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ex : Indisponible sur ce créneau...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le motif de refus est obligatoire'),
                  ),
                );
                return;
              }
              Navigator.of(dialogCtx).pop();
              try {
                await ref
                    .read(serviceRequestsProvider.notifier)
                    .declineRequest(request.id, reason);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demande refusée')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmer le refus'),
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
      case ServiceRequestStatus.packageHandedOver:
        return 'Colis remis';
      case ServiceRequestStatus.inTransit:
        return 'En transit';
      case ServiceRequestStatus.arrivedAtDestination:
        return 'Arrivé à destination';
      case ServiceRequestStatus.delivered:
        return 'Livré';
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
      case ServiceRequestStatus.packageHandedOver:
        return Colors.teal;
      case ServiceRequestStatus.inTransit:
        return Colors.indigo;
      case ServiceRequestStatus.arrivedAtDestination:
        return Colors.amber;
      case ServiceRequestStatus.delivered:
        return Colors.green;
    }
  }

  String _formatDate(DateTime d) {
    final l = d.toLocal();
    return '${l.day.toString().padLeft(2, '0')}/${l.month.toString().padLeft(2, '0')}/${l.year}';
  }
}
