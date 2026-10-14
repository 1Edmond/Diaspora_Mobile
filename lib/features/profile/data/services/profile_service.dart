import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:diaspora_app/core/config/app_config.dart';
import 'package:diaspora_app/features/profile/domain/entities/profile.dart';

import '../models/public_profile_type_model.dart';

class ProfileService {
  final Dio _dio;

  ProfileService({Dio? dio})
    : _dio =
          dio ??
          (GetIt.instance.isRegistered<Dio>()
              ? GetIt.instance<Dio>()
              : _defaultDio());

  static Dio _defaultDio() => Dio(
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
    )
    ..interceptors.addAll([
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
    ]);

  Future<List<Profile>> fetchProfiles() async {
    final res = await _dio.get<Map<String, dynamic>>('/profiles/me');

    if (res.statusCode != 200 || res.data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'fetchProfiles failed: ${res.statusCode}',
      );
    }

    final rawList = res.data!['profiles'] as List<dynamic>? ?? [];
    return rawList
        .map((e) => Profile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PublicProfileType>> fetchPublicProfileTypes() async {
    try {
      final res = await _dio.get('/profile-types/public');
      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List)
            .map((e) => PublicProfileType.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {
      // Fallback below
    }

    // Default seeded countries fallback
    return const [
      PublicProfileType(
        id: 'pt_tg',
        countryCode: 'TG',
        countryName: 'Togo',
        currency: 'XOF',
        phoneIndicatif: '+228',
        flag: '🇹🇬',
      ),
      PublicProfileType(
        id: 'pt_ci',
        countryCode: 'CI',
        countryName: "Côte d'Ivoire",
        currency: 'XOF',
        phoneIndicatif: '+225',
        flag: '🇨🇮',
      ),
      PublicProfileType(
        id: 'pt_bj',
        countryCode: 'BJ',
        countryName: 'Bénin',
        currency: 'XOF',
        phoneIndicatif: '+229',
        flag: '🇧🇯',
      ),
      PublicProfileType(
        id: 'pt_sn',
        countryCode: 'SN',
        countryName: 'Sénégal',
        currency: 'XOF',
        phoneIndicatif: '+221',
        flag: '🇸🇳',
      ),
      PublicProfileType(
        id: 'pt_fr',
        countryCode: 'FR',
        countryName: 'France',
        currency: 'EUR',
        phoneIndicatif: '+33',
        flag: '🇫🇷',
      ),
    ];
  }
}
  