import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tracks the device identity used to bind a user account to a single
/// physical phone at login time (separate from [BiometricKeyService]'s
/// device id, which is scoped to biometric enrollment specifically and
/// only exists for users who opt into biometric login).
///
/// Flow (see AuthNotifier.login()):
/// 1. Every login request sends whatever device id is currently stored
///    locally (nullable — absent on a fresh install).
/// 2. The login response is expected to carry the device id the backend
///    has on file for this account (`DeviceId`/`deviceId`).
/// 3. If nothing was stored locally yet, the API's value is adopted
///    ("bind this device").
/// 4. If a local value already exists and the API returns a *different*
///    one, that means this account is already bound to a different
///    physical device — the login is treated as blocked, since the whole
///    point of this mechanism is to guarantee an account is only ever
///    used from one phone at a time.
class DeviceIdentityService {
  static const _boundDeviceIdKey = 'auth_bound_device_id';

  final FlutterSecureStorage _storage;

  DeviceIdentityService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> getStoredDeviceId() => _storage.read(key: _boundDeviceIdKey);

  Future<void> storeDeviceId(String deviceId) =>
      _storage.write(key: _boundDeviceIdKey, value: deviceId);

  /// Clears the locally bound device id. Only meant for support/recovery
  /// flows (e.g. an explicit "log out everywhere" / "reset my device"
  /// action) — never call this automatically just to work around a
  /// mismatch, or the binding guarantee becomes meaningless.
  Future<void> clear() => _storage.delete(key: _boundDeviceIdKey);
}

/// Thrown by [AuthNotifier.login] when the backend's device id for this
/// account doesn't match the one already bound on this phone.
class DeviceMismatchException implements Exception {
  final String message;
  const DeviceMismatchException([
    this.message =
        'Ce compte est déjà connecté depuis un autre téléphone. '
        'Déconnectez-vous de cet appareil ou contactez le support.',
  ]);

  @override
  String toString() => message;
}
