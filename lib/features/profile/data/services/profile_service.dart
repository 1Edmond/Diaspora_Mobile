import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:diaspora_app/core/config/app_config.dart';
import 'package:diaspora_app/features/profile/domain/entities/profile.dart';

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
    final res = await _dio.get<List<dynamic>>('/profiles/me');

    debugPrint('=== /api/profile RESPONSE ===');
    debugPrint(res.data.toString());

    if (res.statusCode != 200 || res.data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'fetchProfiles failed: ${res.statusCode}',
      );
    }

    return res.data!
        .map((e) => Profile.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
  