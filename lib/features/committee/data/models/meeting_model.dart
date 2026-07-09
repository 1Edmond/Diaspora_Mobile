import '../../domain/entities/meeting.dart';

class MeetingModel extends Meeting {
  MeetingModel({
    required super.id,
    required super.committeeId,
    required super.title,
    required super.description,
    required super.scheduledAt,
    required super.location,
    required super.attendeeIds,
    required super.status,
    super.minutes,
    super.actualStartTime,
    super.actualEndTime,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) => MeetingModel(
    id: json['id'] as String,
    committeeId: json['committeeId'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    scheduledAt: DateTime.parse(json['scheduledAt'] as String),
    location: json['location'] as String,
    attendeeIds: List<String>.from(json['attendeeIds'] as List),
    status: json['status'] as String,
    minutes: json['minutes'] as String?,
    actualStartTime:
        json['actualStartTime'] != null
            ? DateTime.parse(json['actualStartTime'] as String)
            : null,
    actualEndTime:
        json['actualEndTime'] != null
            ? DateTime.parse(json['actualEndTime'] as String)
            : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'committeeId': committeeId,
    'title': title,
    'description': description,
    'scheduledAt': scheduledAt.toIso8601String(),
    'location': location,
    'attendeeIds': attendeeIds,
    'status': status,
    'minutes': minutes,
    'actualStartTime': actualStartTime?.toIso8601String(),
    'actualEndTime': actualEndTime?.toIso8601String(),
  };
}
