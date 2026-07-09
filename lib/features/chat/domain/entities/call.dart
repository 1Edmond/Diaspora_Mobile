import 'package:diaspora_app/core/constants/enums.dart';

class Call {
  final String id;
  final CallType type;
  final String initiatorId;
  final List<String> participants;
  final CallStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final Duration? duration;

  Call({
    required this.id,
    required this.type,
    required this.initiatorId,
    required this.participants,
    required this.status,
    this.startTime,
    this.endTime,
    this.duration,
  });
}
