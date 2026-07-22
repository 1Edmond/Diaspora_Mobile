import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class BiometricKeyService {
  static const _emailKey = 'biometric_email';
  static const _deviceIdKey = 'biometric_device_id';
  static const _privateKeySeedKey = 'biometric_private_key_seed';
  static const _publicKeyKey = 'biometric_public_key';

  final FlutterSecureStorage _storage;
  final Ed25519 _algorithm = Ed25519();

  BiometricKeyService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<bool> isEnrolled() async {
    final email = await _storage.read(key: _emailKey);
    final publicKey = await _storage.read(key: _publicKeyKey);
    final seed = await _storage.read(key: _privateKeySeedKey);
    return email != null && publicKey != null && seed != null;
  }

  Future<String?> getStoredEmail() => _storage.read(key: _emailKey);

  Future<String> getOrCreateDeviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null) return existing;
    final generated = const Uuid().v4();
    await _storage.write(key: _deviceIdKey, value: generated);
    return generated;
  }

  /// Generates a new Ed25519 key pair for this device, stores the private
  /// key seed securely, and returns the raw public key (base64, 32 bytes)
  /// to send to the server for enrollment.
  Future<String> generateAndStoreKeyPair({required String email}) async {
    final keyPair = await _algorithm.newKeyPair();
    final keyPairData = await keyPair.extract();
    final publicKey = await keyPair.extractPublicKey();

    final seedBase64 = base64Encode(keyPairData.bytes);
    final publicKeyBase64 = base64Encode(publicKey.bytes);

    await _storage.write(key: _privateKeySeedKey, value: seedBase64);
    await _storage.write(key: _publicKeyKey, value: publicKeyBase64);
    await _storage.write(key: _emailKey, value: email);

    return publicKeyBase64;
  }

  Future<String?> getStoredPublicKeyBase64() =>
      _storage.read(key: _publicKeyKey);

  /// Signs [message] (UTF-8) with the stored private key and returns the
  /// signature as base64. Returns null if no key pair has been enrolled.
  Future<String?> sign(String message) async {
    final seedBase64 = await _storage.read(key: _privateKeySeedKey);
    if (seedBase64 == null) return null;

    final seed = base64Decode(seedBase64);
    final keyPair = await _algorithm.newKeyPairFromSeed(seed);
    final signature = await _algorithm.sign(
      utf8.encode(message),
      keyPair: keyPair,
    );

    return base64Encode(signature.bytes);
  }

  /// Clears all locally stored biometric enrollment data (email, device id,
  /// key pair). Not wired to logout by default — biometric login is meant
  /// to survive a logout/login cycle on the same device. Call this only
  /// from an explicit "disable biometric login" action, or after a failed
  /// enrollment.
  Future<void> clear() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _deviceIdKey);
    await _storage.delete(key: _privateKeySeedKey);
    await _storage.delete(key: _publicKeyKey);
  }
}
