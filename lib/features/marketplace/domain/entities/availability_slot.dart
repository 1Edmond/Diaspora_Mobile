import 'package:flutter/material.dart';

class AvailabilitySlot {
  final int day;
  final String startTime;
  final String endTime;

  const AvailabilitySlot({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  AvailabilitySlot copyWith({
    int? day,
    String? startTime,
    String? endTime,
  }) {
    return AvailabilitySlot(
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  String getLocalizedDayName(BuildContext context) {
    const days = [
      'Dimanche',
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
    ];
    if (day >= 0 && day < days.length) return days[day];
    return 'Jour $day';
  }

  String getShortDayName(BuildContext context) {
    const days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    if (day >= 0 && day < days.length) return days[day];
    return 'J$day';
  }

  String getFormattedTime(String time) {
    if (time.length >= 5) return time.substring(0, 5);
    return time;
  }

  String getDisplayString(BuildContext context) {
    return '${getShortDayName(context)} ${getFormattedTime(startTime)}-${getFormattedTime(endTime)}';
  }

  bool get isValid {
    return day >= 0 &&
        day <= 6 &&
        startTime.isNotEmpty &&
        endTime.isNotEmpty &&
        startTime != endTime;
  }
}