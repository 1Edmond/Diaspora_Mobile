import 'package:diaspora_app/core/network/token_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../data/models/user_model.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/services/storage_service.dart';
import 'pending_verification_provider.dart';

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
      return AuthNotifier(
        getIt<IAuthRepository>(),
        getIt<ProfileService>(),
        ref: ref,
      );
    });

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final IAuthRepository repository;
  final ProfileService _profileService;
  final TokenService _tokenService;
  final Ref? _ref;
  final StorageService _storage;

  AuthNotifier(
    this.repository,
    this._profileService, {
    TokenService? tokenService,
    Ref? ref,
    StorageService? storage,
  }) : _tokenService = tokenService ?? TokenService(),
       _ref = ref,
       _storage = storage ?? StorageService(),
       super(const AsyncValue.data(null)) {
    _restorePendingVerification();
  }

  String? _lastAccessToken;
  String? get lastAccessToken => _lastAccessToken;

  Future<bool> restoreSession() async {
    return repository.ensureAuthenticated();
  }

  void _restorePendingVerification() {
    final email = _storage.get<String>('pendingVerificationEmail');
    if (email != null && email.isNotEmpty) {
      _ref?.read(pendingVerificationEmailProvider.notifier).state = email;
    }
  }

  Future<bool> register({
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required DateTime dateOfBirth,
    required String userType,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.register(
        phone: phone,
        password: password,
        firstName: firstName,
        lastName: lastName,
        email: email,
        dateOfBirth: dateOfBirth,
        userType: userType,
      );
      _ref?.read(pendingVerificationEmailProvider.notifier).state = email;
      await _storage.save('pendingVerificationEmail', email);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> verifyEmail(String email, String code) async {
    state = const AsyncValue.loading();
    try {
      final ok = await repository.verifyEmail(email, code);
      if (ok) {
        _ref?.read(pendingVerificationEmailProvider.notifier).state = null;
        await _storage.remove('pendingVerificationEmail');
      }
      state = const AsyncValue.data(null);
      return ok;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> cancelRegistration() async {
    _ref?.read(pendingVerificationEmailProvider.notifier).state = null;
    await _storage.remove('pendingVerificationEmail');
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final res = await repository.login(email, password);
      final u = (res['user'] ?? res['User']) as Map<String, dynamic>? ?? {};
      final phoneMap =
          (u['phoneNumber'] ?? u['PhoneNumber']) as Map<String, dynamic>?;
      final phone =
          phoneMap != null
              ? '${phoneMap['CountryCode'] ?? phoneMap['countryCode'] ?? ''}${phoneMap['Value'] ?? phoneMap['value'] ?? ''}'
              : '';
      final userId =
          (u['id'] ?? u['Id'] ?? res['userId'] ?? res['UserId'])?.toString();
      final user = UserModel.fromJson({
        'id': userId,
        'email': (u['email'] ?? u['Email'] ?? email) as String,
        'phone': phone,
      });
      _lastAccessToken = (res['accessToken'] ?? res['AccessToken']) as String?;

      state = AsyncValue.data(user);
      fetchProfiles();
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> loginWithBiometricTokens(Map<String, dynamic> json) async {
    state = const AsyncValue.loading();
    try {
      final u = (json['user'] ?? json['User']) as Map<String, dynamic>? ?? {};
      final phoneMap =
          (u['phoneNumber'] ?? u['PhoneNumber']) as Map<String, dynamic>?;
      final phone =
          phoneMap != null
              ? '${phoneMap['CountryCode'] ?? phoneMap['countryCode'] ?? ''}${phoneMap['Value'] ?? phoneMap['value'] ?? ''}'
              : '';
      final userId =
          (u['id'] ?? u['Id'] ?? json['userId'] ?? json['UserId'])?.toString();
      final email = (u['email'] ?? u['Email']) as String? ?? '';

      final user = UserModel.fromJson({
        'id': userId,
        'email': email,
        'phone': phone,
      });

      final accessToken =
          (json['accessToken'] ?? json['AccessToken']) as String?;
      final refreshToken =
          (json['refreshToken'] ?? json['RefreshToken']) as String?;
      
      final refreshExpiryRaw = json['refreshTokenExpiry'] ?? json['RefreshTokenExpiry'] ?? json['expiresAt'] ?? json['ExpiresAt'];
      DateTime? refreshTokenExpiry;
      if (refreshExpiryRaw is String) {
        refreshTokenExpiry = DateTime.tryParse(refreshExpiryRaw);
      } else if (refreshExpiryRaw is int) {
        refreshTokenExpiry = DateTime.now().add(Duration(seconds: refreshExpiryRaw));
      }

      final accessExpiryRaw = json['accessTokenExpiry'] ?? json['AccessTokenExpiry'] ?? json['expiresIn'] ?? json['ExpiresIn'];
      DateTime? accessTokenExpiry;
      if (accessExpiryRaw is String) {
        accessTokenExpiry = DateTime.tryParse(accessExpiryRaw);
      } else if (accessExpiryRaw is int) {
        accessTokenExpiry = DateTime.now().add(Duration(seconds: accessExpiryRaw));
      }

      await _tokenService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiry: accessTokenExpiry,
        refreshTokenExpiry: refreshTokenExpiry,
      );

      _lastAccessToken = accessToken;

      state = AsyncValue.data(user);
      fetchProfiles();
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await repository.logout();
    } catch (e) {
      debugPrint('logout failed: $e');
    } finally {
      _ref?.read(activeProfileIdProvider.notifier).clear();
      state = const AsyncValue.data(null);
    }
  }

  Future<void> fetchProfiles() async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      _ref?.read(profileListProvider.notifier).setLoading();
      final profiles = await _profileService.fetchProfiles();
      _ref?.read(profileListProvider.notifier).setProfiles(profiles);
      state = AsyncValue.data(current.copyWith(profiles: profiles));

      final activeId = _ref?.read(activeProfileIdProvider);
      if (activeId == null && profiles.isNotEmpty) {
        _ref?.read(activeProfileIdProvider.notifier).setActiveProfileId(profiles.first.id);
      }
    } catch (e, st) {
      debugPrint('fetchProfiles failed: $e');
      _ref?.read(profileListProvider.notifier).setError(e, st);
    }
  }
}
