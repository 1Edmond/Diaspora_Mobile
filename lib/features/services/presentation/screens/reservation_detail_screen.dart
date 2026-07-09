import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../data/mock/mock_services.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../data/models/reservation_model.dart';

class ReservationDetailScreen extends StatefulWidget {
  final String reservationId;
  const ReservationDetailScreen({required this.reservationId, super.key});

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  late ReservationModel _reservation;
  int _rating = 0;
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final raw = mockReservations.firstWhere(
      (r) => r['id'] == widget.reservationId,
      orElse: () => mockReservations.first,
    );
    _reservation = ReservationModel.fromJson(raw);
    _rating = _reservation.rating ?? 0;
    _commentCtrl.text = _reservation.comment ?? '';
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
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
    final r = _reservation;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Réservation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeumorphicContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.handyman_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.serviceTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: AppColors.getTextMain(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor(r.status).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _statusLabel(r.status),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _statusColor(r.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.05),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(label: 'Date', value: '${r.date.day}/${r.date.month}/${r.date.year} à ${r.date.hour}h${r.date.minute.toString().padLeft(2, '0')}'),
                  const Divider(height: 20),
                  _InfoRow(label: 'Prix', value: '${r.price.toStringAsFixed(0)} ${r.currency}'),
                  const Divider(height: 20),
                  _InfoRow(label: 'Référence', value: r.id),
                  if (r.notes != null) ...[
                    const Divider(height: 20),
                    _InfoRow(label: 'Notes', value: r.notes!),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 80.ms),
            if (r.status == 'COMPLETED') ...[
              const SizedBox(height: 24),
              Text(
                'Donner votre avis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextMain(context),
                ),
              ),
              const SizedBox(height: 12),
              NeumorphicContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final filled = i < _rating;
                        return GestureDetector(
                          onTap: () => setState(() => _rating = i + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              filled ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 36,
                              color: filled ? AppColors.warning : AppColors.getTextSecondary(context),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _commentCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Partagez votre expérience...',
                        hintStyle: TextStyle(color: AppColors.getTextSecondary(context)),
                        filled: true,
                        fillColor: AppColors.getBackground(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Merci pour votre avis !')),
                          );
                        },
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Envoyer mon avis'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 120.ms),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: TextStyle(fontSize: 13, color: AppColors.getTextSecondary(context))),
        ),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.getTextMain(context))),
        ),
      ],
    );
  }
}
