class AvailabilitySlotModel {
  final int day;
  final String startTime;
  final String endTime;

  const AvailabilitySlotModel({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory AvailabilitySlotModel.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlotModel(
      day: (json['Day'] ?? json['day'] ?? 0) as int,
      startTime: (json['StartTime'] ?? json['startTime'] ?? '00:00:00') as String,
      endTime: (json['EndTime'] ?? json['endTime'] ?? '23:59:59') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'Day': day,
    'StartTime': startTime,
    'EndTime': endTime,
  };
}