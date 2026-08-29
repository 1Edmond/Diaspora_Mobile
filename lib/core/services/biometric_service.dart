import 'package:dio/dio.dart';
import 'package:local_auth/local_auth.dart';
import '../config/app_config.dart';
import 'biometric_key_service.dart';

/// Result of a biometric authentication attempt.
enum BiometricResult {
  success,
  notAvailable,
  notEnrolled,
  failed,
  canceled,
  unknown,
}

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final BiometricKeyService _keyService;

  BiometricService({BiometricKeyService? keyService})
    : _keyService = keyService ?? BiometricKeyService();

  /// Returns true if the device supports biometric authentication AND
  /// the user has enrolled at least one biometric (fingerprint/face).
  Future<bool> get isAvailable async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if this device already has a biometric key pair
  /// enrolled with the server for some account.
  Future<bool> get isEnrolled => _keyService.isEnrolled();

  /// Removes this device's biometric enrollment. Only clears the local key
  /// material for now — if the backend later exposes a revoke endpoint
  /// (e.g. POST /auth/biometric/unenroll), call it here first so the
  /// server-side key is invalidated too, not just the local copy.
  Future<void> disenroll() => _keyService.clear();

  /// Prompts the user to authenticate with biometrics.
  /// Returns [BiometricResult.success] if the user successfully authenticated.
  Future<BiometricResult> authenticate({
    String reason = 'Authentifiez-vous pour accéder à votre compte',
  }) async {
    try {
      final available = await isAvailable;
      if (!available) return BiometricResult.notAvailable;

      final didAuth = await _localAuth.authenticate(
        localizedReason: reason,

        options: const AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: true,
          biometricOnly: false,
        ),
      );
      return didAuth ? BiometricResult.success : BiometricResult.canceled;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('notavailable') || msg.contains('not available')) {
        return BiometricResult.notAvailable;
      }
      if (msg.contains('notenrolled') || msg.contains('not enrolled')) {
        return BiometricResult.notEnrolled;
      }
      return BiometricResult.unknown;
    }
  }

  /// Enrolls this device for biometric login. Must be called right after a
  /// successful password login, passing the freshly issued [accessToken] —
  /// the enrollment endpoint requires authentication.
  Future<bool> enroll({
    required String email,
    required String accessToken,
  }) async {
    try {
      final publicKeyBase64 = await _keyService.generateAndStoreKeyPair(
        email: email,
      );
      final deviceId = await _keyService.getOrCreateDeviceId();

      final res = await _biometricDio.post<Map<String, dynamic>>(
        '/auth/biometric/enroll',
        data: {'DeviceId': deviceId, 'PublicKey': publicKeyBase64},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final ok =
          res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300;
      if (!ok) {
        await _keyService.clear();
      }
      return ok;
    } catch (_) {
      await _keyService.clear();
      return false;
    }
  }

  /// Combines a local fingerprint scan with the challenge-response flow
  /// against the server. No email input needed: it is read from local
  /// secure storage, set at enrollment time.
  /// Returns the raw JSON login response (accessToken/refreshToken/user)
  /// via [BiometricAuthResponse.tokens] on success.
  Future<BiometricAuthResponse> authenticateAndLogin({
    String reason = 'Authentifiez-vous pour accéder à votre compte',
  }) async {
    final email = await _keyService.getStoredEmail();
    if (email == null) {
      return BiometricAuthResponse(
        success: false,
        result: BiometricResult.notEnrolled,
        tokens: null,
        error: 'Aucune empreinte enregistrée pour ce compte sur cet appareil',
      );
    }

    final result = await authenticate(reason: reason);
    if (result != BiometricResult.success) {
      return BiometricAuthResponse(
        success: false,
        result: result,
        tokens: null,
        error: _messageFor(result),
      );
    }

    try {
      final deviceId = await _keyService.getOrCreateDeviceId();

      final challengeRes = await _biometricDio.post<Map<String, dynamic>>(
        '/auth/biometric/challenge',
        data: {'Email': email, 'DeviceId': deviceId},
      );
      if (challengeRes.statusCode == null ||
          challengeRes.statusCode! < 200 ||
          challengeRes.statusCode! >= 300) {
        return BiometricAuthResponse(
          success: false,
          result: BiometricResult.failed,
          tokens: null,
          error:
              'Impossible d\'obtenir un défi du serveur (code ${challengeRes.statusCode})',
        );
      }

      final challengeData = challengeRes.data ?? <String, dynamic>{};
      final nonce =
          (challengeData['nonce'] ?? challengeData['Nonce']) as String?;
      if (nonce == null) {
        return BiometricAuthResponse(
          success: false,
          result: BiometricResult.failed,
          tokens: null,
          error: 'Réponse du serveur invalide (nonce manquant)',
        );
      }

      final signature = await _keyService.sign(nonce);
      if (signature == null) {
        return BiometricAuthResponse(
          success: false,
          result: BiometricResult.notEnrolled,
          tokens: null,
          error: 'Aucune clé enregistrée pour signer le défi',
        );
      }

      final loginRes = await _biometricDio.post<Map<String, dynamic>>(
        '/auth/biometric/login',
        data: {
          'Email': email,
          'DeviceId': deviceId,
          'Nonce': nonce,
          'Signature': signature,
        },
      );

      if (loginRes.statusCode == null ||
          loginRes.statusCode! < 200 ||
          loginRes.statusCode! >= 300) {
        return BiometricAuthResponse(
          success: false,
          result: BiometricResult.failed,
          tokens: null,
          error:
              'Échec de l\'authentification biométrique (code ${loginRes.statusCode})',
        );
      }

      final data = loginRes.data ?? <String, dynamic>{};
      return BiometricAuthResponse(
        success: true,
        result: BiometricResult.success,
        tokens: data,
        error: null,
      );
    } catch (e) {
      return BiometricAuthResponse(
        success: false,
        result: BiometricResult.failed,
        tokens: null,
        error: 'Erreur réseau: $e',
      );
    }
  }

  Dio get _biometricDio => Dio(
    BaseOptions(
      baseUrl: AppConfig.realApiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (_) => true,
      headers: {
        'Content-Type': 'application/json',
        'x-client-key': AppConfig.clientKey,
      },
    ),
  );

  String _messageFor(BiometricResult r) {
    switch (r) {
      case BiometricResult.notAvailable:
        return 'L\'authentification biométrique n\'est pas disponible sur cet appareil';
      case BiometricResult.notEnrolled:
        return 'Aucune empreinte enregistrée. Configurez-la dans les paramètres de l\'appareil';
      case BiometricResult.canceled:
        return 'Authentification annulée';
      case BiometricResult.failed:
        return 'Échec de l\'authentification';
      case BiometricResult.unknown:
        return 'Erreur inconnue';
      case BiometricResult.success:
        return '';
    }
  }
}

class BiometricAuthResponse {
  final bool success;
  final BiometricResult result;
  final Map<String, dynamic>? tokens;
  final String? error;

  BiometricAuthResponse({
    required this.success,
    required this.result,
    required this.tokens,
    required this.error,
  });
}
