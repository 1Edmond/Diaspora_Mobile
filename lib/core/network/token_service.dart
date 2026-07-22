import '../../../shared/services/storage_service.dart';

class TokenService {
  final StorageService _storage;
  String? _refreshingToken;
  Future<String?>? _refreshFuture;

  TokenService({StorageService? storage}) : _storage = storage ?? StorageService();

  String? get accessToken => _storage.get<String>('accessToken');
  String? get refreshToken => _storage.get<String>('refreshToken');
  DateTime? get accessTokenExpiry => _readExpiry('accessTokenExpiry');
  DateTime? get refreshTokenExpiry => _readExpiry('refreshTokenExpiry');

  bool get hasAccessToken => accessToken != null && accessToken!.isNotEmpty;
  bool get hasRefreshToken => refreshToken != null && refreshToken!.isNotEmpty;

  bool get isAccessTokenExpired {
    final exp = accessTokenExpiry;
    if (exp == null) return false;
    return DateTime.now().isAfter(exp);
  }

  bool get isRefreshTokenExpired {
    final exp = refreshTokenExpiry;
    if (exp == null) return false;
    return DateTime.now().isAfter(exp);
  }

  Future<void> saveTokens({
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiry,
    DateTime? refreshTokenExpiry,
  }) async {
    if (accessToken != null) {
      await _storage.save('accessToken', accessToken);
    }
    if (refreshToken != null) {
      await _storage.save('refreshToken', refreshToken);
    }
    if (accessTokenExpiry != null) {
      await _storage.save('accessTokenExpiry', accessTokenExpiry.toIso8601String());
    }
    if (refreshTokenExpiry != null) {
      await _storage.save('refreshTokenExpiry', refreshTokenExpiry.toIso8601String());
    }
  }

  /// Try to ensure we have a valid access token.
  /// If expired, refreshes using refresh token.
  /// Returns the access token, or null if it could not be obtained.
  Future<String?> ensureValidAccessToken({
    required Future<String?> Function(String refreshToken) refreshCallback,
  }) async {
    if (!isAccessTokenExpired) return accessToken;
    if (!hasRefreshToken || isRefreshTokenExpired) return null;
    return refresh(refreshCallback);
  }

  /// Force refresh. Avoids concurrent refresh calls.
  Future<String?> refresh(
    Future<String?> Function(String refreshToken) refreshCallback,
  ) async {
    final current = refreshToken;
    if (current == null || current.isEmpty) return null;

    if (_refreshingToken == current && _refreshFuture != null) {
      return _refreshFuture;
    }
    _refreshingToken = current;
    _refreshFuture = _doRefresh(current, refreshCallback);
    try {
      return await _refreshFuture;
    } finally {
      _refreshingToken = null;
      _refreshFuture = null;
    }
  }

  Future<String?> _doRefresh(
    String refreshToken,
    Future<String?> Function(String refreshToken) refreshCallback,
  ) async {
    try {
      final newAccess = await refreshCallback(refreshToken);
      if (newAccess == null) return null;
      return newAccess;
    } catch (_) {
      return null;
    }
  }

void clearTokens() {
    _storage.remove('accessToken');
    _storage.remove('refreshToken');
    _storage.remove('accessTokenExpiry');
    _storage.remove('refreshTokenExpiry');
  }

  DateTime? _readExpiry(String key) {
    final raw = _storage.get<String>(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }
}