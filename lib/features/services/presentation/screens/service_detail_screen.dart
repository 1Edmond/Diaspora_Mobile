import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../domain/entities/service.dart';
import '../controllers/services_notifier.dart';
import '../../data/models/service_model.dart';

class ServiceDetailScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final bool isOwn;
  const ServiceDetailScreen({required this.serviceId, this.isOwn = false, super.key});

  @override
  ConsumerState<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ServiceModel?>(
      future: ref.read(servicesProvider.notifier).getDetail(widget.serviceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Service')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: AppColors.getTextSecondary(context)),
                  const SizedBox(height: 12),
                  Text('Service non trouvé', style: TextStyle(color: AppColors.getTextSecondary(context))),
                ],
              ),
            ),
          );
        }
        final s = snapshot.data!;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary.withValues(alpha: 0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -40,
                          right: -40,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: -30,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                title: Text(s.title, style: const TextStyle(color: Colors.white, fontSize: 18)),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NeumorphicContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _InfoChip(
                                  icon: Icons.star_rounded,
                                  label: s.rating.toString(),
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 8),
                                _InfoChip(
                                  icon: Icons.reviews_rounded,
                                  label: '${s.reviewCount} avis',
                                  color: AppColors.primary,
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${s.price.toStringAsFixed(0)} ${s.currency}${s.priceType == PriceType.PER_HOUR ? '/h' : ''}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideY(begin: 0.1),
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextMain(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Informations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextMain(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _InfoRow(label: 'Zone', value: _scopeLabel(s.scope)),
                            if (s.allowedDepartments != null) ...[
                              const Divider(height: 20),
                              _InfoRow(label: 'Départements', value: s.allowedDepartments!.join(', ')),
                            ],
                            const Divider(height: 20),
                            _InfoRow(label: 'Type de prix', value: _priceTypeLabel(s.priceType)),
                            const Divider(height: 20),
                            _InfoRow(label: 'Statut', value: s.status == 'ACTIVE' ? 'Actif' : s.status),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.chat_rounded),
                          label: const Text('Contacter le prestataire'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: widget.isOwn
                              ? () => context.push('/services/${s.id}/edit')
                              : () => _showBookingDialog(context, s.title),
                          icon: Icon(widget.isOwn ? Icons.edit_rounded : Icons.calendar_today_rounded),
                          label: Text(widget.isOwn ? 'Modifier le service' : 'Réserver ce service'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBookingDialog(BuildContext context, String serviceTitle) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final timeCtrl = TextEditingController(text: '10:00');
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.getBackground(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                    ),
                    const SizedBox(height: 20),
                    Text('Réserver', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.getTextMain(context))),
                    const SizedBox(height: 4),
                    Text(serviceTitle, style: TextStyle(fontSize: 13, color: AppColors.getTextSecondary(context))),
                    const SizedBox(height: 20),
                    Text('Date souhaitée', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.getTextMain(context))),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setDialogState(() => selectedDate = date);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.getBackground(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.getTextSecondary(context)),
                            const SizedBox(width: 10),
                            Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: TextStyle(fontSize: 14, color: AppColors.getTextMain(context)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Heure', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.getTextMain(context))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: timeCtrl,
                      decoration: InputDecoration(
                        hintText: '10:00',
                        filled: true,
                        fillColor: AppColors.getBackground(context),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Notes supplémentaires', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.getTextMain(context))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Ex: Je préfère en matinée...',
                        filled: true,
                        fillColor: AppColors.getBackground(context),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Demande de réservation envoyée pour le ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}')),
                          );
                        },
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Envoyer la demande'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _scopeLabel(ServiceScope scope) {
    switch (scope) {
      case ServiceScope.CITY_ONLY: return 'Ville uniquement';
      case ServiceScope.COUNTRY_WIDE: return 'National';
      case ServiceScope.DEPARTMENT_LIST: return 'Départements spécifiques';
    }
  }

  String _priceTypeLabel(PriceType type) {
    switch (type) {
      case PriceType.FIXED: return 'Prix fixe';
      case PriceType.PER_HOUR: return 'Par heure';
      case PriceType.NEGOTIABLE: return 'Négociable';
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.getTextMain(context))),
      ],
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: AppColors.getTextSecondary(context))),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.getTextMain(context))),
      ],
    );
  }
}
