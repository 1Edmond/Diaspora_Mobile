import '../../domain/entities/enums.dart';

class JobCategoryModel {
  final String id;
  final String name;
  final String? description;
  final bool isActive;

  const JobCategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  factory JobCategoryModel.fromJson(Map<String, dynamic> json) {
    return JobCategoryModel(
      id: _str(json, 'Id', 'id'),
      name: _str(json, 'Name', 'name'),
      description: _strOrNull(json, 'Description', 'description'),
      isActive: _bool(json, 'IsActive', 'isActive'),
    );
  }

  static String _str(Map<String, dynamic> json, String pascal, String camel) =>
      (json[pascal] ?? json[camel] ?? '') as String;

  static String? _strOrNull(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return null;
    return val as String;
  }

  static bool _bool(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return false;
    if (val is bool) return val;
    if (val is String) return val.toLowerCase() == 'true';
    return val == 1;
  }
}

class JobTemplateModel {
  final String id;
  final String employerId;
  final String name;
  final String? description;
  final String categoryId;
  final List<String> requiredSkills;
  final List<String> requiredDocuments;
  final int defaultCapacity;
  final double defaultAmount;
  final String defaultCurrency;
  final PaymentType defaultPaymentType;
  final PaymentTiming defaultPaymentTiming;
  final CheckInMethod defaultCheckInMethod;
  final int? defaultGeofenceRadiusMeters;
  final bool defaultRequiresKyc;

  const JobTemplateModel({
    required this.id,
    required this.employerId,
    required this.name,
    this.description,
    required this.categoryId,
    required this.requiredSkills,
    required this.requiredDocuments,
    required this.defaultCapacity,
    required this.defaultAmount,
    required this.defaultCurrency,
    required this.defaultPaymentType,
    required this.defaultPaymentTiming,
    required this.defaultCheckInMethod,
    this.defaultGeofenceRadiusMeters,
    required this.defaultRequiresKyc,
  });

  factory JobTemplateModel.fromJson(Map<String, dynamic> json) {
    final pt = _int(json, 'DefaultPaymentType', 'defaultPaymentType');
    return JobTemplateModel(
      id: _str(json, 'Id', 'id'),
      employerId: _str(json, 'EmployerId', 'employerId'),
      name: _str(json, 'Name', 'name'),
      description: _strOrNull(json, 'Description', 'description'),
      categoryId: _str(json, 'CategoryId', 'categoryId'),
      requiredSkills: _stringList(json, 'RequiredSkills', 'requiredSkills'),
      requiredDocuments: _stringList(json, 'RequiredDocuments', 'requiredDocuments'),
      defaultCapacity: _int(json, 'DefaultCapacity', 'defaultCapacity'),
      defaultAmount: _doubleOrZero(json, 'DefaultAmount', 'defaultAmount'),
      defaultCurrency: _str(json, 'DefaultCurrency', 'defaultCurrency'),
      defaultPaymentType: PaymentType.values[pt.clamp(0, PaymentType.values.length - 1)],
      defaultPaymentTiming: PaymentTiming.values[_int(json, 'DefaultPaymentTiming', 'defaultPaymentTiming').clamp(0, PaymentTiming.values.length - 1)],
      defaultCheckInMethod: CheckInMethod.values[_int(json, 'DefaultCheckInMethod', 'defaultCheckInMethod').clamp(0, CheckInMethod.values.length - 1)],
      defaultGeofenceRadiusMeters: _intOrNull(json, 'DefaultGeofenceRadiusMeters', 'defaultGeofenceRadiusMeters'),
      defaultRequiresKyc: _bool(json, 'DefaultRequiresKyc', 'defaultRequiresKyc'),
    );
  }

  static String _str(Map<String, dynamic> json, String pascal, String camel) =>
      (json[pascal] ?? json[camel] ?? '') as String;

  static String? _strOrNull(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return null;
    return val as String;
  }

  static int _int(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return 0;
    return (val as num).toInt();
  }

  static int? _intOrNull(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return null;
    return (val as num).toInt();
  }

  static double _doubleOrZero(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return 0.0;
    return (val as num).toDouble();
  }

  static bool _bool(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return false;
    if (val is bool) return val;
    if (val is String) return val.toLowerCase() == 'true';
    return val == 1;
  }

  static List<String> _stringList(Map<String, dynamic> json, String pascal, String camel) {
    final raw = json[pascal] ?? json[camel];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }
}