import 'package:geolocator/geolocator.dart';

/// Thin wrapper over `geolocator` to request permission and capture the
/// current position, shared by the Freelance search (distance filter) and
/// the geo check-in feature. Centralizing it here keeps the permission flow
/// consistent (don't re-request if already granted).
class LocationService {
  Future<bool> isPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> requestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Returns the current position, throwing if permission is denied or
  /// location services are disabled. Callers should wrap in try/catch and
  /// surface a friendly error.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Le service de localisation est désactivé.');
    }
    final granted = await requestPermission();
    if (!granted) {
      throw const LocationException('Permission de localisation refusée.');
    }
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);
  @override
  String toString() => message;
}

final locationService = LocationService();