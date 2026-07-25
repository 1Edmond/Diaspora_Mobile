import 'location_model.dart';

class ProcedureModel {
  final String id;
  final String title;
  final String description;
  final num costAmount;
  final String costCurrency;
  final String profileType;
  final String profileTypeId;
  final int estimatedDurationDays;
  final bool isActive;
  final List<LocationModel> locations;
  final List<String> dependencyIds;
  final List<String> requiredDocumentTypeIds;
  final List<String> outputDocumentType;
  final DateTime createdAt;
  final int userProgress;

  ProcedureModel({
    required this.id,
    required this.title,
    required this.description,
    required this.costAmount,
    required this.costCurrency,
    required this.profileType,
    required this.profileTypeId,
    required this.estimatedDurationDays,
    required this.isActive,
    this.locations = const [],
    this.dependencyIds = const [],
    this.requiredDocumentTypeIds = const [],
    this.outputDocumentType = const [],
    required this.createdAt,
    this.userProgress = 0,
  });

  DateTime? get deadline {
    if (estimatedDurationDays <= 0) return null;
    return createdAt.add(Duration(days: estimatedDurationDays));
  }

  ProcedureModel copyWith({
    int? userProgress,
    List<LocationModel>? locations,
  }) {
    return ProcedureModel(
      id: id,
      title: title,
      description: description,
      costAmount: costAmount,
      costCurrency: costCurrency,
      profileType: profileType,
      profileTypeId: profileTypeId,
      estimatedDurationDays: estimatedDurationDays,
      isActive: isActive,
      locations: locations ?? this.locations,
      dependencyIds: dependencyIds,
      requiredDocumentTypeIds: requiredDocumentTypeIds,
      outputDocumentType: outputDocumentType,
      createdAt: createdAt,
      userProgress: userProgress ?? this.userProgress,
    );
  }

  factory ProcedureModel.fromJson(Map<String, dynamic> json) {
    final locationsJson = json['locations'] as List<dynamic>?;
    final dependencyIdsJson = json['dependencyIds'] as List<dynamic>?;
    final requiredDocumentTypeIdsJson = json['requiredDocumentTypeIds'] as List<dynamic>?;
    final outputDocumentTypeJson = json['outputDocumentType'] as List<dynamic>?;
    return ProcedureModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      costAmount: json['costAmount'] as num,
      costCurrency: json['costCurrency'] as String,
      profileType: json['profileType'] as String,
      profileTypeId: json['profileTypeId'] as String,
      estimatedDurationDays: json['estimatedDurationDays'] as int,
      isActive: json['isActive'] as bool,
      locations: locationsJson != null
          ? locationsJson.map((e) => LocationModel.fromJson(e as Map<String, dynamic>)).toList()
          : [],
      dependencyIds: dependencyIdsJson != null
          ? dependencyIdsJson.map((e) => e as String).toList()
          : [],
      requiredDocumentTypeIds: requiredDocumentTypeIdsJson != null
          ? requiredDocumentTypeIdsJson.map((e) => e as String).toList()
          : [],
      outputDocumentType: outputDocumentTypeJson != null
          ? outputDocumentTypeJson.map((e) => e as String).toList()
          : [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}