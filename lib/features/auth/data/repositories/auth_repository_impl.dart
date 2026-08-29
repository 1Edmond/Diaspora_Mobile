import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/token_service.dart';
import '../../../../shared/services/storage_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final Dio _dio;
  final TokenService _tokenService;

  AuthRepositoryImpl({Dio? client, StorageService? storage, TokenService? tokenService})
    : _dio =
          (client ?? Dio(_defaultOptions()))
            ..interceptors.addAll([
              if (kDebugMode)
                LogInterceptor(requestBody: true, responseBody: true),
            ]),
      _tokenService = tokenService ?? TokenService(storage: storage);

  static BaseOptions _defaultOptions() => BaseOptions(
    baseUrl: AppConfig.realApiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    validateStatus: (_) => true,
    headers: {
      'Content-Type': 'application/json',
      'x-client-key': AppConfig.clientKey,
    },
  );

  @override
  String? get accessToken => _tokenService.accessToken;
  String? get refreshToken => _tokenService.refreshToken;
  bool get isAccessTokenExpired => _tokenService.isAccessTokenExpired;
  bool get isRefreshTokenExpired => _tokenService.isRefreshTokenExpired;
  TokenService get tokenService => _tokenService;

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final accessExpiry = _parseExpiry(
      data['accessTokenExpiry'] ?? data['AccessTokenExpiry'] ?? data['expiresIn'] ?? data['ExpiresIn'],
    );
    final refreshExpiry = _parseExpiry(data['refreshTokenExpiry'] ?? data['RefreshTokenExpiry']);
    await _tokenService.saveTokens(
      accessToken: (data['accessToken'] ?? data['AccessToken']) as String?,
      refreshToken: (data['refreshToken'] ?? data['RefreshToken']) as String?,
      accessTokenExpiry: accessExpiry,
      refreshTokenExpiry: refreshExpiry,
    );
  }

  DateTime? _parseExpiry(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is int) {
      return DateTime.now().add(Duration(seconds: value));
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required DateTime dateOfBirth,
    required String userType,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'PhoneNumber': phone,
        'Password': password,
        'FirstName': firstName,
        'LastName': lastName,
        'Email': email,
        'DateOfBirth':
            "${dateOfBirth.year.toString().padLeft(4, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}",
        'UserType': userType,
        'Role': ["User"],
      },
    );
    if (res.statusCode == null ||
        res.statusCode! < 200 ||
        res.statusCode! >= 300) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'Registration failed with status ${res.statusCode}',
      );
    }
    final data = (res.data as Map<String, dynamic>?) ?? <String, dynamic>{};
    await _saveTokens(data);
    return data;
  }

  @override
  Future<bool> verifyEmail(String email, String code) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/verify-email',
      data: {'Email': email, 'Code': code},
    );
    if (res.statusCode == null ||
        res.statusCode! < 200 ||
        res.statusCode! >= 300) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'Email verification failed with status ${res.statusCode}',
      );
    }
    final data = (res.data as Map<String, dynamic>?) ?? <String, dynamic>{};
    await _saveTokens(data);
    return data['ok'] as bool? ?? true;
  }

  @override
  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    String? deviceId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'Email': email,
        'Password': password,
        // Sent on every login attempt so the backend can enforce (or at
        // least track) single-device binding per account. See
        // AuthNotifier.login() for the local comparison/storage logic.
        if (deviceId != null) 'DeviceId': deviceId,
      },
    );
    if (res.statusCode == null ||
        res.statusCode! < 200 ||
        res.statusCode! >= 300) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'Login failed with status ${res.statusCode}',
      );
    }
    final data = (res.data as Map<String, dynamic>?) ?? <String, dynamic>{};
    await _saveTokens(data);
    return data;
  }

  /// Calls the refresh endpoint to get a new access token.
  /// Returns the new access token on success, or null on failure.
  Future<String?> refreshAccessToken() async {
    final current = refreshToken;
    if (current == null || current.isEmpty) return null;
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh-token',
        data: {'refreshToken': current},
      );
      if (res.statusCode == null ||
          res.statusCode! < 200 ||
          res.statusCode! >= 300) {
        return null;
      }
      final data = (res.data as Map<String, dynamic>?) ?? <String, dynamic>{};
      final newAccess = data['accessToken'] as String?;
      if (newAccess == null || newAccess.isEmpty) return null;
      await _saveTokens(data);
      return newAccess;
    } catch (_) {
      return null;
    }
  }

  /// Validates the current auth state. If the access token is expired but
  /// the refresh token is still valid, attempts to refresh. Returns true if
  /// the user is now authenticated, false if they need to log in again.
  Future<bool> ensureAuthenticated() async {
    if (!_tokenService.hasAccessToken) return false;
    if (!_tokenService.isAccessTokenExpired) return true;
    if (!_tokenService.hasRefreshToken || _tokenService.isRefreshTokenExpired) {
      return false;
    }
    final newAccess = await refreshAccessToken();
    return newAccess != null;
  }

  @override
  Future<void> logout() async {
    _tokenService.clearTokens();
  }
}
