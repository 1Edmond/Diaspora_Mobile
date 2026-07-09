import 'package:diaspora_app/core/constants/enums.dart';

class Mentorship {
  final String id;
  final String mentorId;
  final String menteeId;
  final MentorshipStatus status;
  final List<String> topics;
  final DateTime? startDate;
  final String? notes;

  Mentorship({
    required this.id,
    required this.mentorId,
    required this.menteeId,
    required this.status,
    required this.topics,
    this.startDate,
    this.notes,
  });
}
