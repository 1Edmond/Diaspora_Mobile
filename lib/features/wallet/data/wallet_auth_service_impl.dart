import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/wallet_auth_service.dart';

/// Lightweight Wallet PIN / Biometric helper for the app and tests.
/// - Stores PIN in `flutter_secure_storage` under `wallet_pin` (MVP).
/// - Uses `local_auth` for biometric flows when available.
/// NOTE: for production persist a *hashed* PIN and apply rate-limiting.
class WalletAuthServiceImpl implements IWalletAuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const _pinKey = 'wallet_pin';

  @override
  Future<bool> isPinSet() async => (await _storage.read(key: _pinKey)) != null;

  @override
  Future<void> setPin(String pin) async {
    // TODO: hash+salt the PIN for production. Keeping plain in secure storage
    // for the MVP / testability because flutter_secure_storage is encrypted.
    await _storage.write(key: _pinKey, value: pin);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    return stored != null && stored == pin;
  }

  @override
  Future<void> clearPin() async => await _storage.delete(key: _pinKey);

  @override
  Future<bool> canCheckBiometrics() async {
    try {
      final can = await _localAuth.canCheckBiometrics;
      return can;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometrics({
    String reason = 'Authenticate',
  }) async {
    try {
      // In unit tests / CI this will typically throw / return false — caller
      // should handle gracefully.
      final didAuth = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: false,
        ),
      );
      return didAuth;
    } catch (e) {
      if (kDebugMode) {
        // swallow native errors in debug/test runs
        debugPrint('WalletAuth: biometric auth not available: $e');
      }
      return false;
    }
  }
}
