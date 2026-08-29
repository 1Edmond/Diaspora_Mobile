import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../core/services/location_service.dart';
import '../../data/models/freelance_dtos.dart';
import '../../domain/entities/enums.dart';
import '../controllers/freelance_providers.dart';
import '../controllers/freelance_providers_ext.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  final String applicationId;
  final CheckInMethod method;

  const CheckInScreen({
    super.key,
    required this.applicationId,
    required this.method,
  });

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  bool _busy = false;

  Future<void> _checkIn() async {
    setState(() => _busy = true);
    try {
      double? lat;
      double? lng;
      if (widget.method == CheckInMethod.geoLocation) {
        final pos = await locationService.getCurrentPosition();
        lat = pos.latitude;
        lng = pos.longitude;
      }
      final dto = CreateJobCheckInDto(
        method: widget.method.index,
        latitude: lat,
        longitude: lng,
      );
      await ref
          .read(freelanceRepositoryProvider)
          .createCheckIn(widget.applicationId, dto);
      if (!mounted) return;
      ref.invalidate(checkInsProvider(widget.applicationId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pointage enregistré.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pointage impossible : $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkOut(String checkInId) async {
    setState(() => _busy = true);
    try {
      await ref.read(freelanceRepositoryProvider).checkOut(checkInId);
      if (!mounted) return;
      ref.invalidate(checkInsProvider(widget.applicationId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pointage terminé.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final checkInsAsync = ref.watch(checkInsProvider(widget.applicationId));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pointage',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  widget.method == CheckInMethod.geoLocation
                      ? Icons.location_on_rounded
                      : widget.method == CheckInMethod.qrCode
                          ? Icons.qr_code_scanner_rounded
                          : widget.method == CheckInMethod.pinCode
                              ? Icons.pin_rounded
                              : Icons.person_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.method == CheckInMethod.manualByEmployer
                      ? 'Pointage par l\'employeur — aucune action requise.'
                      : 'Méthode : ${widget.method.name}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (widget.method != CheckInMethod.manualByEmployer)
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _busy ? null : _checkIn,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                ),
                child: _busy
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Pointer mon arrivée'),
              ),
            ),
          const Divider(),
          Expanded(
            child: checkInsAsync.when(
              data: (items) => items.isEmpty
                  ? const Center(child: Text('Aucun pointage.'))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final c = items[index];
                        return ListTile(
                          leading: Icon(
                            c.status == CheckInStatus.checkedOut
                                ? Icons.check_circle_rounded
                                : Icons.access_time_rounded,
                            color: AppColors.primary,
                          ),
                          title: Text('Arrivée: ${_time(c.checkInAt)}'),
                          subtitle: Text(
                              c.checkOutAt != null
                                  ? 'Sortie: ${_time(c.checkOutAt!)}'
                                  : 'En cours'),
                          trailing: c.status == CheckInStatus.checkedIn
                              ? IconButton(
                                  icon: const Icon(Icons.logout_rounded),
                                  onPressed: _busy ? null : () => _checkOut(c.id),
                                )
                              : null,
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur : $e')),
            ),
          ),
        ],
      ),
    );
  }

  String _time(DateTime d) {
    final l = d.toLocal();
    return '${l.day}/${l.month} ${l.hour}h${l.minute.toString().padLeft(2, '0')}';
  }
}