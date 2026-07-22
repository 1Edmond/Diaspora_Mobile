class DayScheduleModel {
  final String day;
  final bool isClosed;
  final String? openTime;
  final String? closeTime;

  DayScheduleModel({
    required this.day,
    required this.isClosed,
    this.openTime,
    this.closeTime,
  });

  factory DayScheduleModel.fromJson(Map<String, dynamic> json) => DayScheduleModel(
        day: json['day'] as String,
        isClosed: json['isClosed'] as bool,
        openTime: json['openTime'] as String?,
        closeTime: json['closeTime'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'isClosed': isClosed,
        'openTime': openTime,
        'closeTime': closeTime,
      };
}