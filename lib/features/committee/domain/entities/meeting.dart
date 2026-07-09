class Meeting {
  final String id;
  final String committeeId;
  final String title;
  final String description;
  final DateTime scheduledAt;
  final String location;
  final List<String> attendeeIds;
  final String status; // SCHEDULED, ONGOING, COMPLETED, CANCELLED
  final String? minutes;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;

  Meeting({
    required this.id,
    required this.committeeId,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.location,
    required this.attendeeIds,
    required this.status,
    this.minutes,
    this.actualStartTime,
    this.actualEndTime,
  });
}
