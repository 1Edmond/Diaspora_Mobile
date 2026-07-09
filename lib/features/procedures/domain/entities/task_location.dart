class TaskLocation {
  final String name;
  final String address;
  final String city;
  final String? phoneNumber;
  final String? openingHours;
  final Map<String, double>? mapCoordinates; // lat, lng

  TaskLocation({
    required this.name,
    required this.address,
    required this.city,
    this.phoneNumber,
    this.openingHours,
    this.mapCoordinates,
  });
}
