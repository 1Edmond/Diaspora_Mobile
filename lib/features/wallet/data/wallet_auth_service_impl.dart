import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../domain/wallet_auth_service.dart';

/// Secure Wallet PIN and Biometric service.
/// - Stores a salted SHA-256 hash of the PIN in `flutter_secure_storage`.
/// - Supports legacy plain-text PIN migration transparently.
/// - Implements lockout after 5 consecutive failed attempts (5-minute cooldown).
/// - Uses `local_auth` for biometric flows when available.
class WalletAuthServiceImpl implements IWalletAuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  static const _pinHashKey = 'wallet_pin_hash';
  static const _pinSaltKey = 'wallet_pin_salt';
  static const _legacyPinKey = 'wallet_pin';
  static const _failedAttemptsKey = 'wallet_pin_failed_attempts';
  static const _lockedUntilKey = 'wallet_pin_locked_until';

  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 5);

  @override
  Future<bool> isPinSet() async {
    final hash = await _storage.read(key: _pinHashKey);
    if (hash != null && hash.isNotEmpty) return true;
    final legacy = await _storage.read(key: _legacyPinKey);
    return legacy != null && legacy.isNotEmpty;
  }

  @override
  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);

    await _storage.write(key: _pinHashKey, value: hash);
    await _storage.write(key: _pinSaltKey, value: salt);

    // Delete legacy plain-text pin if present
    await _storage.delete(key: _legacyPinKey);

    // Reset lockout counters on new PIN setup
    await _resetLockout();
  }

  @override
  Future<bool> verifyPin(String pin) async {
    // 1. Check lockout status
    if (await isLockedOut()) {
      return false;
    }

    final storedHash = await _storage.read(key: _pinHashKey);
    final storedSalt = await _storage.read(key: _pinSaltKey);

    if (storedHash != null && storedSalt != null) {
      final computedHash = _hashPin(pin, storedSalt);
      final isMatch = computedHash == storedHash;
      if (isMatch) {
        await _resetLockout();
        return true;
      } else {
        await _recordFailedAttempt();
        return false;
      }
    }

    // 2. Fallback / migration for legacy plain-text PIN
    final legacyPin = await _storage.read(key: _legacyPinKey);
    if (legacyPin != null && legacyPin.isNotEmpty) {
      final isMatch = legacyPin == pin;
      if (isMatch) {
        // Upgrade to hashed+salted PIN immediately
        await setPin(pin);
        return true;
      } else {
        await _recordFailedAttempt();
        return false;
      }
    }

    return false;
  }

  @override
  Future<void> clearPin() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinSaltKey);
    await _storage.delete(key: _legacyPinKey);
    await _resetLockout();
  }

  /// Returns true if currently locked out due to too many failed attempts.
  Future<bool> isLockedOut() async {
    final lockedUntilStr = await _storage.read(key: _lockedUntilKey);
    if (lockedUntilStr != null && lockedUntilStr.isNotEmpty) {
      final lockedUntil = DateTime.tryParse(lockedUntilStr);
      if (lockedUntil != null && DateTime.now().isBefore(lockedUntil)) {
        return true;
      }
    }
    return false;
  }

  /// Returns the lockout expiry date if currently locked out, null otherwise.
  Future<DateTime?> getLockoutExpiry() async {
    final lockedUntilStr = await _storage.read(key: _lockedUntilKey);
    if (lockedUntilStr != null && lockedUntilStr.isNotEmpty) {
      final lockedUntil = DateTime.tryParse(lockedUntilStr);
      if (lockedUntil != null && DateTime.now().isBefore(lockedUntil)) {
        return lockedUntil;
      }
    }
    return null;
  }

  /// Returns the current number of consecutive failed attempts.
  Future<int> getFailedAttempts() async {
    final str = await _storage.read(key: _failedAttemptsKey);
    return str != null ? int.tryParse(str) ?? 0 : 0;
  }

  Future<void> _recordFailedAttempt() async {
    final current = await getFailedAttempts();
    final newCount = current + 1;
    await _storage.write(key: _failedAttemptsKey, value: newCount.toString());

    if (newCount >= maxFailedAttempts) {
      final lockUntil = DateTime.now().add(lockoutDuration);
      await _storage.write(key: _lockedUntilKey, value: lockUntil.toIso8601String());
    }
  }

  Future<void> _resetLockout() async {
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockedUntilKey);
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hashPin(String pin, String salt) {
    final combined = utf8.encode('$salt:$pin');
    return sha256.convert(combined).toString();
  }

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
        debugPrint('WalletAuth: biometric auth not available: $e');
      }
      return false;
    }
  }
}
