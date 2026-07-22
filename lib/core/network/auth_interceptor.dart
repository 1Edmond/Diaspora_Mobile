import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'token_service.dart';

/// Interceptor that:
/// 1. Attaches the access token to outbound requests (Authorization: Bearer ...)
/// 2. If the token is expired, attempts to refresh ONCE before sending
/// 3. If the server returns 401/403, attempts to refresh and retries the request
class AuthInterceptor extends Interceptor {
  final TokenService _tokenService;
  final Dio _refreshDio;
  bool _isRefreshing = false;

  AuthInterceptor(this._tokenService, this._refreshDio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenService.ensureValidAccessToken(
      refreshCallback: _refreshAccessToken,
    );
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      final refreshed = await _refreshAccessToken(_tokenService.refreshToken ?? '');
      if (refreshed != null) {
        try {
          final options = err.requestOptions
            ..headers['Authorization'] = 'Bearer $refreshed';
          final response = await Dio().fetch(options);
          handler.resolve(response);
          return;
        } catch (e) {
          _tokenService.clearTokens();
        }
      }
    }
    handler.next(err);
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    if (_isRefreshing) return null;
    if (refreshToken.isEmpty) return null;

    _isRefreshing = true;
    try {
      final res = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-client-key': AppConfig.clientKey,
          },
          validateStatus: (_) => true,
        ),
      );
      if (res.statusCode == null ||
          res.statusCode! < 200 ||
          res.statusCode! >= 300) {
        return null;
      }
      final data = res.data ?? <String, dynamic>{};
      final newAccess = (data['accessToken'] ?? data['AccessToken']) as String?;
      final newRefresh = (data['refreshToken'] ?? data['RefreshToken']) as String?;
      final accessExpiry = _parseExpiry(
        data['accessTokenExpiry'] ?? data['AccessTokenExpiry'] ?? data['expiresIn'] ?? data['ExpiresIn'],
      );
      final refreshExpiry = _parseExpiry(data['refreshTokenExpiry'] ?? data['RefreshTokenExpiry']);

      await _tokenService.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
        accessTokenExpiry: accessExpiry,
        refreshTokenExpiry: refreshExpiry,
      );
      return newAccess;
    } catch (_) {
      return null;
    } finally {
      _isRefreshing = false;
    }
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
}