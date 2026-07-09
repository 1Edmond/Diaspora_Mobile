import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../data/mock/mock_services.dart';
import '../../data/models/reservation_model.dart';
import '../../../../shared/widgets/containers/glass_container.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  String _filter = 'ALL';

  List<ReservationModel> get _reservations {
    final raw = mockReservations.map((e) => ReservationModel.fromJson(e)).toList();
    raw.sort((a, b) => b.date.compareTo(a.date));
    if (_filter == 'ALL') return raw;
    return raw.where((r) => r.status == _filter).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMED': return AppColors.accent;
      case 'PENDING': return AppColors.warning;
      case 'COMPLETED': return AppColors.primary;
      case 'CANCELLED': return Colors.grey;
      default: return AppColors.getTextSecondary(context);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'CONFIRMED': return 'Confirmé';
      case 'PENDING': return 'En attente';
      case 'COMPLETED': return 'Terminé';
      case 'CANCELLED': return 'Annulé';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _reservations;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Mes Réservations',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextMain(context),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: ['ALL', 'CONFIRMED', 'PENDING', 'COMPLETED', 'CANCELLED'].map((f) {
                    final labels = {
                      'ALL': 'Toutes',
                      'CONFIRMED': 'Confirmées',
                      'PENDING': 'En attente',
                      'COMPLETED': 'Terminées',
                      'CANCELLED': 'Annulées',
                    };
                    final selected = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : AppColors.getBackground(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? AppColors.primary : AppColors.getTextSecondary(context).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            labels[f]!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : AppColors.getTextSecondary(context),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (items.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy_rounded, size: 48, color: AppColors.getTextSecondary(context)),
                      const SizedBox(height: 12),
                      Text('Aucune réservation', style: TextStyle(color: AppColors.getTextSecondary(context))),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final r = items[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => context.push('/reservations/${r.id}'),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _statusColor(r.status).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    r.status == 'COMPLETED' ? Icons.check_circle_rounded :
                                    r.status == 'CANCELLED' ? Icons.cancel_rounded :
                                    r.status == 'CONFIRMED' ? Icons.event_available_rounded :
                                    Icons.schedule_rounded,
                                    color: _statusColor(r.status),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.serviceTitle,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.getTextMain(context),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${r.date.day}/${r.date.month}/${r.date.year} à ${r.date.hour}h${r.date.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(fontSize: 12, color: AppColors.getTextSecondary(context)),
                                      ),
                                      if (r.notes != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          r.notes!,
                                          style: TextStyle(fontSize: 11, color: AppColors.getTextSecondary(context)),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _statusColor(r.status).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _statusLabel(r.status),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _statusColor(r.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
