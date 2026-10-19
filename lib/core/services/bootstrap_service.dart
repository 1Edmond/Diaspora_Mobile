import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../config/feature_flags.dart';
import '../network/dio_client.dart';

class BootstrapService {
  BootstrapService._();

  static Future<void> initialize({String? profileTypeId, String? countryCode}) async {
    try {
      if (!GetIt.instance.isRegistered<DioClient>()) {
        if (kDebugMode) {
          print('[BootstrapService] DioClient not registered yet, using local default config.');
        }
        return;
      }

      final queryParams = <String, String>{};
      if (profileTypeId != null && profileTypeId.isNotEmpty) {
        queryParams['profileTypeId'] = profileTypeId;
        AppConfig.currentProfileTypeId = profileTypeId;
      }
      if (countryCode != null && countryCode.isNotEmpty) {
        queryParams['countryCode'] = countryCode;
      }

      final queryString = queryParams.isNotEmpty
          ? '?${queryParams.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&')}'
          : '';

      final client = GetIt.instance<DioClient>();
      final response = await client.get<Map<String, dynamic>>('/config/mobile$queryString');

      if (response.containsKey('activeModules') && response['activeModules'] is Map) {
        final activeModules = Map<String, dynamic>.from(response['activeModules'] as Map);
        FeatureFlags.updateFromRemote(activeModules);
        if (kDebugMode) {
          print('[BootstrapService] Remote feature flags applied: $activeModules');
        }
      }

      if (response.containsKey('parcelTransportCategoryId') &&
          response['parcelTransportCategoryId'] != null) {
        AppConfig.parcelTransportCategoryId =
            response['parcelTransportCategoryId'].toString();
        if (kDebugMode) {
          print('[BootstrapService] Parcel transport category ID set to: ${AppConfig.parcelTransportCategoryId}');
        }
      }

      if (response.containsKey('supportedLocales') &&
          response['supportedLocales'] is List) {
        AppConfig.supportedLocales =
            List<String>.from(response['supportedLocales'] as List);
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('[BootstrapService] Remote bootstrap failed (retaining defaults): $e\n$stack');
      }
    }
  }
}
