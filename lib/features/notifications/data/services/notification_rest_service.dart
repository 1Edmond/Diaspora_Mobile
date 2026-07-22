import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/config/app_config.dart';

class NotificationRestService {
  final Dio _dio;

  NotificationRestService({Dio? dio})
    : _dio = dio ??
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
      )..interceptors.addAll([
          if (kDebugMode)
            LogInterceptor(requestBody: true, responseBody: true),
        ]);

  Future<List<Map<String, dynamic>>> fetchUnread({
    required String userId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: {'pageNumber': 1, 'pageSize': 50, 'unreadOnly': true},
    );

    if (res.statusCode != 200) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'fetchUnread failed: ${res.statusCode}',
      );
    }

    final items = res.data?['items'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<void> markAsRead({
    required String notificationId,
  }) async {
    final res = await _dio.patch(
      '/notifications/$notificationId/read',
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'markAsRead failed: ${res.statusCode}',
      );
    }
  }
}
