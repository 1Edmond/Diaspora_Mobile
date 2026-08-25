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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final validSlots = slots.where((s) => s.isValid).toList();

    if (validSlots.isEmpty) {
      return _buildEmptyState(context);
    }

    final byDay = <int, List<AvailabilitySlotModel>>{};
    for (final slot in validSlots) {
      byDay.putIfAbsent(slot.day, () => []).add(slot);
    }

    final daysWithSlots = byDay.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusBadge(context),
        const SizedBox(height: 12),
        ...daysWithSlots.map((day) {
          final daySlots = byDay[day]!..sort((a, b) => a.startTime.compareTo(b.startTime));
          return _buildDayRow(context, day, daySlots);
        }),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isAvailableNow ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailableNow ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailableNow ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 18,
            color: isAvailableNow ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            isAvailableNow ? 'Disponible maintenant' : 'Actuellement indisponible',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isAvailableNow ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, int day, List<AvailabilitySlotModel> daySlots) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayName = _getDayName(day);
    final daySlotsSorted = List<AvailabilitySlotModel>.from(daySlots)
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
        children: [
          Container(
            width: 50,
            child: Text(
              dayName,
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
              children: daySlotsSorted.map((slot) => _buildTimeChip(context, slot)).toList(),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
    }

  Widget _buildTimeChip(BuildContext context, AvailabilitySlotModel slot) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        '${slot.startTime.length >= 5 ? slot.startTime.substring(0, 5) : slot.startTime} - ${slot.endTime.length >= 5 ? slot.endTime.substring(0, 5) : slot.endTime}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(duration: 200.ms, curve: Curves.easeOutBack);
  }

  String _getDayName(int day) {
    const days = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
    if (day >= 0 && day < days.length) return days[day];
    return 'Jour $day';
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            child: Icon(Icons.schedule_rounded, color: AppColors.primary, size: 28),
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
                  'Le prestataire n\'a pas encore défini ses créneaux horaires.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn().slideX(begin: 0.1, end: 0),
    );
  }
}