import 'package:diaspora_app/core/constants/enums.dart';

class Event {
  final String id;
  final String organizerId;
  final String title;
  final String description;
  final EventType type;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final bool isOnline;
  final String? meetingLink;
  final int? maxParticipants;
  final List<String> participants;
  final String? coverImage;
  final List<String> tags;

  Event({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.location,
    this.isOnline = false,
    this.meetingLink,
    this.maxParticipants,
    this.participants = const [],
    this.coverImage,
    this.tags = const [],
  });
}
