import 'day_schedule_model.dart';

class LocationModel {
  final String id;
  final String name;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? website;
  final List<DayScheduleModel> schedule;

  LocationModel({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.website,
    this.schedule = const [],
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final scheduleJson = json['schedule'] as List<dynamic>?;
    return LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      schedule: scheduleJson != null
          ? scheduleJson.map((e) => DayScheduleModel.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'street': street,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'phoneNumber': phoneNumber,
        'website': website,
        'schedule': schedule.map((e) => e.toJson()).toList(),
      };
}