import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/paged_response.dart';
import '../models/procedure_model.dart';
import '../models/location_model.dart';
import '../models/day_schedule_model.dart';

class ProcedureService {
  final Dio _dio;

  ProcedureService({Dio? dio})
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

  // --- Mappings pour les enums .NET sérialisés en int par System.Text.Json ---

  static const Map<int, String> _profileTypeLabels = {
    0: 'Internal',
    1: 'External',
  };

  static const Map<int, String> _dayOfWeekLabels = {
    0: 'Sunday',
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
  };

  /// Résout une valeur d'enum qui peut arriver en int (C#) ou déjà en String.
  String _resolveEnumLabel(
    dynamic raw,
    Map<int, String> labels,
    String fallback,
  ) {
    if (raw is String) return raw;
    if (raw is int) return labels[raw] ?? fallback;
    return fallback;
  }

  Future<PagedResponse<ProcedureModel>> fetchProcedures({
    int profileType = 0,
    String? profileTypeId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/procedure',
      queryParameters: {
        'profileType': profileType,
        'profileTypeId': profileTypeId,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    if (res.statusCode != 200 || res.data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'fetchProcedures failed: ${res.statusCode}',
      );
    }

    try {
      return PagedResponse.fromJson(res.data!, _parseProcedureItem);
    } catch (e, st) {
      if (kDebugMode) {
        print('Erreur de parsing PagedResponse<ProcedureModel>: $e');
        print(st);
      }
      rethrow;
    }
  }

  ProcedureModel _parseProcedureItem(Map<String, dynamic> json) {
    final id = (json['Id'] ?? json['id']) as String? ?? '';
    final title = (json['Title'] ?? json['title']) as String? ?? '';
    final description =
        (json['Description'] ?? json['description']) as String? ?? '';

    final locations = _parseLocations(json);
    final dependencyIds = _parseStringList(
      json,
      'DependencyIds',
      'dependencyIds',
    );
    final requiredDocumentTypeIds = _parseStringList(
      json,
      'RequiredDocumentTypeIds',
      'requiredDocumentTypeIds',
    );

    return ProcedureModel(
      id: id,
      title: title,
      description: description,
      costAmount: (json['CostAmount'] ?? json['costAmount'] ?? 0) as num,
      costCurrency:
          (json['CostCurrency'] ?? json['costCurrency'] ?? 'XOF') as String,
      profileType: _resolveEnumLabel(
        json['ProfileType'] ?? json['profileType'],
        _profileTypeLabels,
        'Internal',
      ),
      profileTypeId:
          (json['ProfileTypeId'] ?? json['profileTypeId'] ?? '') as String,
      estimatedDurationDays:
          (json['EstimatedDurationDays'] ?? json['estimatedDurationDays'] ?? 0)
              as int,
      isActive: (json['IsActive'] ?? json['isActive'] ?? true) as bool,
      locations: locations,
      dependencyIds: dependencyIds,
      requiredDocumentTypeIds: requiredDocumentTypeIds,
      createdAt:
          _parseDateTime(json, 'CreatedAt', 'createdAt') ?? DateTime.now(),
      userProgress: (json['UserProgress'] ?? json['userProgress'] ?? 0) as int,
    );
  }

  List<dynamic> _parseList(
    Map<String, dynamic> json,
    String pascalKey,
    String camelKey,
  ) {
    final raw = json[pascalKey] ?? json[camelKey];
    if (raw is List) return raw;
    return [];
  }

  List<String> _parseStringList(
    Map<String, dynamic> json,
    String pascalKey,
    String camelKey,
  ) {
    final raw = _parseList(json, pascalKey, camelKey);
    return raw.map((e) => e.toString()).toList();
  }

  List<LocationModel> _parseLocations(Map<String, dynamic> json) {
    final raw = _parseList(json, 'Locations', 'locations');
    return raw
        .map((e) => _parseLocation(e as Map<String, dynamic>))
        .whereType<LocationModel>()
        .toList();
  }

  LocationModel? _parseLocation(Map<String, dynamic> json) {
    final id = (json['Id'] ?? json['id']) as String?;
    if (id == null || id.isEmpty) return null;

    final scheduleRaw = _parseList(json, 'Schedule', 'schedule');
    final schedule =
        scheduleRaw
            .map((e) => _parseDaySchedule(e as Map<String, dynamic>))
            .whereType<DayScheduleModel>()
            .toList();

    return LocationModel(
      id: id,
      name: (json['Name'] ?? json['name']) as String? ?? '',
      street: (json['Street'] ?? json['street']) as String? ?? '',
      city: (json['City'] ?? json['city']) as String? ?? '',
      state: (json['State'] ?? json['state']) as String? ?? '',
      postalCode: (json['PostalCode'] ?? json['postalCode']) as String? ?? '',
      country: (json['Country'] ?? json['country']) as String? ?? '',
      latitude: ((json['Latitude'] ?? json['latitude'] ?? 0) as num).toDouble(),
      longitude:
          ((json['Longitude'] ?? json['longitude'] ?? 0) as num).toDouble(),
      phoneNumber: (json['PhoneNumber'] ?? json['phoneNumber']) as String?,
      website: (json['Website'] ?? json['website']) as String?,
      schedule: schedule,
    );
  }

  DayScheduleModel _parseDaySchedule(Map<String, dynamic> json) {
    return DayScheduleModel(
      day: _resolveEnumLabel(json['Day'] ?? json['day'], _dayOfWeekLabels, ''),
      isClosed: (json['IsClosed'] ?? json['isClosed'] ?? false) as bool,
      openTime: (json['OpenTime'] ?? json['openTime']) as String?,
      closeTime: (json['CloseTime'] ?? json['closeTime']) as String?,
    );
  }

  Future<void> startProcedure({
    required String profileId,
    required String procedureId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/user-procedures/start',
      data: {'ProfileId': profileId, 'ProcedureId': procedureId},
    );
    if (res.statusCode == null ||
        res.statusCode! < 200 ||
        res.statusCode! >= 300) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'startProcedure failed: ${res.statusCode}',
      );
    }
  }

  Future<void> completeProcedure({
    required String procedureId,
    required String profileId,
    required bool isInternal,
  }) async {
    final body = isInternal
        ? {'InternalProfileId': profileId, 'Notes': ''}
        : {'ExternalProfileId': profileId, 'Notes': ''};
    final res = await _dio.post<Map<String, dynamic>>(
      '/user-procedures/$procedureId/complete',
      data: body,
    );
    if (res.statusCode == null ||
        res.statusCode! < 200 ||
        res.statusCode! >= 300) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'completeProcedure failed: ${res.statusCode}',
      );
    }
  }

  DateTime? _parseDateTime(
    Map<String, dynamic> json,
    String pascalKey,
    String camelKey,
  ) {
    final raw = json[pascalKey] ?? json[camelKey];
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }
}
