import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../shared/services/storage_service.dart';

class TokenService {
  final FlutterSecureStorage _secureStorage;
  final StorageService _legacyStorage;

  String? _refreshingToken;
  Future<String?>? _refreshFuture;

  // In-memory cache for synchronous and instantaneous access
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  DateTime? _cachedAccessTokenExpiry;
  DateTime? _cachedRefreshTokenExpiry;
  bool _initialized = false;
  Future<void>? _initFuture;

  TokenService({
    FlutterSecureStorage? secureStorage,
    StorageService? storage,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _legacyStorage = storage ?? StorageService() {
    _initFuture = _initFromStorage();
  }

  Future<void> _initFromStorage() async {
    if (_initialized) return;
    try {
      // 1. Attempt to read from FlutterSecureStorage
      _cachedAccessToken = await _secureStorage.read(key: 'accessToken');
      _cachedRefreshToken = await _secureStorage.read(key: 'refreshToken');
      final accExp = await _secureStorage.read(key: 'accessTokenExpiry');
      final refExp = await _secureStorage.read(key: 'refreshTokenExpiry');
      _cachedAccessTokenExpiry = _parseDateTime(accExp);
      _cachedRefreshTokenExpiry = _parseDateTime(refExp);

      // 2. Migration from legacy Hive storage if secure storage was empty
      if (_cachedAccessToken == null && _cachedRefreshToken == null) {
        final legacyAccess = _legacyStorage.get<String>('accessToken');
        final legacyRefresh = _legacyStorage.get<String>('refreshToken');
        final legacyAccExp = _parseDateTime(_legacyStorage.get<String>('accessTokenExpiry'));
        final legacyRefExp = _parseDateTime(_legacyStorage.get<String>('refreshTokenExpiry'));

        if (legacyAccess != null || legacyRefresh != null) {
          _cachedAccessToken = legacyAccess;
          _cachedRefreshToken = legacyRefresh;
          _cachedAccessTokenExpiry = legacyAccExp;
          _cachedRefreshTokenExpiry = legacyRefExp;

          // Persist to secure storage
          await _writeSecure('accessToken', legacyAccess);
          await _writeSecure('refreshToken', legacyRefresh);
          await _writeSecure('accessTokenExpiry', legacyAccExp?.toIso8601String());
          await _writeSecure('refreshTokenExpiry', legacyRefExp?.toIso8601String());

          // Clean up legacy plain text storage
          await _legacyStorage.remove('accessToken');
          await _legacyStorage.remove('refreshToken');
          await _legacyStorage.remove('accessTokenExpiry');
          await _legacyStorage.remove('refreshTokenExpiry');
        }
      }
    } catch (_) {
      // Fallback: If secure storage throws (e.g. in certain unsupported environments), fallback to legacy
      _cachedAccessToken ??= _legacyStorage.get<String>('accessToken');
      _cachedRefreshToken ??= _legacyStorage.get<String>('refreshToken');
      _cachedAccessTokenExpiry ??= _parseDateTime(_legacyStorage.get<String>('accessTokenExpiry'));
      _cachedRefreshTokenExpiry ??= _parseDateTime(_legacyStorage.get<String>('refreshTokenExpiry'));
    } finally {
      _initialized = true;
    }
  }

  Future<void> _writeSecure(String key, String? value) async {
    if (value != null) {
      await _secureStorage.write(key: key, value: value);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  String? get accessToken {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    return _legacyStorage.get<String>('accessToken');
  }

  String? get refreshToken {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    return _legacyStorage.get<String>('refreshToken');
  }

  DateTime? get accessTokenExpiry {
    if (_cachedAccessTokenExpiry != null) return _cachedAccessTokenExpiry;
    return _readExpiryLegacy('accessTokenExpiry');
  }

  DateTime? get refreshTokenExpiry {
    if (_cachedRefreshTokenExpiry != null) return _cachedRefreshTokenExpiry;
    return _readExpiryLegacy('refreshTokenExpiry');
  }

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
      _cachedAccessToken = accessToken;
      try {
        await _secureStorage.write(key: 'accessToken', value: accessToken);
      } catch (_) {
        await _legacyStorage.save('accessToken', accessToken);
      }
    }
    if (refreshToken != null) {
      _cachedRefreshToken = refreshToken;
      try {
        await _secureStorage.write(key: 'refreshToken', value: refreshToken);
      } catch (_) {
        await _legacyStorage.save('refreshToken', refreshToken);
      }
    }
    if (accessTokenExpiry != null) {
      _cachedAccessTokenExpiry = accessTokenExpiry;
      try {
        await _secureStorage.write(key: 'accessTokenExpiry', value: accessTokenExpiry.toIso8601String());
      } catch (_) {
        await _legacyStorage.save('accessTokenExpiry', accessTokenExpiry.toIso8601String());
      }
    }
    if (refreshTokenExpiry != null) {
      _cachedRefreshTokenExpiry = refreshTokenExpiry;
      try {
        await _secureStorage.write(key: 'refreshTokenExpiry', value: refreshTokenExpiry.toIso8601String());
      } catch (_) {
        await _legacyStorage.save('refreshTokenExpiry', refreshTokenExpiry.toIso8601String());
      }
    }
  }

  /// Try to ensure we have a valid access token.
  /// If expired, refreshes using refresh token.
  /// Returns the access token, or null if it could not be obtained.
  Future<String?> ensureValidAccessToken({
    required Future<String?> Function(String refreshToken) refreshCallback,
  }) async {
    if (_initFuture != null) {
      await _initFuture;
    }
    if (!isAccessTokenExpired && hasAccessToken) return accessToken;
    if (!hasRefreshToken || isRefreshTokenExpired) return null;
    return refresh(refreshCallback);
  }

  /// Force refresh. Avoids concurrent refresh calls.
  Future<String?> refresh(
    Future<String?> Function(String refreshToken) refreshCallback,
  ) async {
    if (_initFuture != null) {
      await _initFuture;
    }
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
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedAccessTokenExpiry = null;
    _cachedRefreshTokenExpiry = null;

    try {
      _secureStorage.delete(key: 'accessToken');
      _secureStorage.delete(key: 'refreshToken');
      _secureStorage.delete(key: 'accessTokenExpiry');
      _secureStorage.delete(key: 'refreshTokenExpiry');
    } catch (_) {}

    _legacyStorage.remove('accessToken');
    _legacyStorage.remove('refreshToken');
    _legacyStorage.remove('accessTokenExpiry');
    _legacyStorage.remove('refreshTokenExpiry');
  }

  DateTime? _readExpiryLegacy(String key) {
    final raw = _legacyStorage.get<String>(key);
    return _parseDateTime(raw);
  }

  DateTime? _parseDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }
}