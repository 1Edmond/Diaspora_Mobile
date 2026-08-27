import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/availability_slot_model.dart';

class AvailabilityWidget extends StatelessWidget {
  final List<AvailabilitySlotModel> slots;
  final bool isAvailableNow;

  const AvailabilityWidget({
    super.key,
    required this.slots,
    required this.isAvailableNow,
  });

  static const _dayNames = [
    'Dimanche',
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final validSlots =
        slots.where((s) => s.isValid).toList();

    if (validSlots.isEmpty) {
      return _buildEmptyState(isDark);
    }

    final byDay = <int, List<AvailabilitySlotModel>>{};
    for (final slot in validSlots) {
      byDay.putIfAbsent(slot.day, () => []).add(slot);
    }
    final days = byDay.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statusBadge(),
        const SizedBox(height: 12),
        for (final day in days)
          _dayRow(context, isDark, day, byDay[day]!),
      ],
    );
  }

  Widget _statusBadge() {
    final color = isAvailableNow ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailableNow
                ? Icons.check_circle_rounded
                : Icons.schedule_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            isAvailableNow
                ? 'Disponible maintenant'
                : 'Actuellement indisponible',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayRow(
    BuildContext context,
    bool isDark,
    int day,
    List<AvailabilitySlotModel> daySlots,
  ) {
    final sortedSlots = List<AvailabilitySlotModel>.from(daySlots)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              day >= 0 && day <= 6 ? _dayNames[day] : 'Jour $day',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children:
                  sortedSlots.map((s) => _timeChip(s)).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _timeChip(AvailabilitySlotModel slot) {
    String short(String t) => t.length >= 5 ? t.substring(0, 5) : t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        '${short(slot.startTime)} - ${short(slot.endTime)}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.schedule_rounded,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aucune disponibilité définie',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Le prestataire n'a pas encore défini ses créneaux horaires.",
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
