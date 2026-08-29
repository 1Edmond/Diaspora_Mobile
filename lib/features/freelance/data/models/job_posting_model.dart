import '../../domain/entities/enums.dart';
import 'json_helpers.dart';

class JobPostingModel {
  final String id;
  final String employerId;
  final String employerName;
  final String? templateId;
  final String categoryId;
  final String categoryName;
  final String title;
  final String description;
  final int capacity;
  final int acceptedCount;
  final double amount;
  final String currency;
  final PaymentType paymentType;
  final PaymentTiming paymentTiming;
  final CheckInMethod checkInMethod;
  final int? geofenceRadiusMeters;
  final bool requiresKycVerification;
  final DateTime eventStartAt;
  final DateTime eventEndAt;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final bool isRemote;
  final List<String> requiredSkills;
  final List<String> requiredDocuments;
  final DateTime? registrationDeadline;
  final JobPostingStatus status;
  final DateTime createdAt;

  const JobPostingModel({
    required this.id,
    required this.employerId,
    required this.employerName,
    this.templateId,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.capacity,
    required this.acceptedCount,
    required this.amount,
    required this.currency,
    required this.paymentType,
    required this.paymentTiming,
    required this.checkInMethod,
    this.geofenceRadiusMeters,
    required this.requiresKycVerification,
    required this.eventStartAt,
    required this.eventEndAt,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    required this.isRemote,
    required this.requiredSkills,
    required this.requiredDocuments,
    this.registrationDeadline,
    required this.status,
    required this.createdAt,
  });

  int get remainingPlaces => (capacity - acceptedCount).clamp(0, capacity);

  factory JobPostingModel.fromJson(Map<String, dynamic> json) {
    return JobPostingModel(
      id: jstr(json, 'Id', 'id'),
      employerId: jstr(json, 'EmployerId', 'employerId'),
      employerName: jstr(json, 'EmployerName', 'employerName'),
      templateId: jstrOrNull(json, 'TemplateId', 'templateId'),
      categoryId: jstr(json, 'CategoryId', 'categoryId'),
      categoryName: jstr(json, 'CategoryName', 'categoryName'),
      title: jstr(json, 'Title', 'title'),
      description: jstr(json, 'Description', 'description'),
      capacity: jint(json, 'Capacity', 'capacity'),
      acceptedCount: jint(json, 'AcceptedCount', 'acceptedCount'),
      amount: jdouble(json, 'Amount', 'amount'),
      currency: jstr(json, 'Currency', 'currency'),
      paymentType: PaymentType.values[jint(json, 'PaymentType', 'paymentType').clamp(0, PaymentType.values.length - 1)],
      paymentTiming: PaymentTiming.values[jint(json, 'PaymentTiming', 'paymentTiming').clamp(0, PaymentTiming.values.length - 1)],
      checkInMethod: CheckInMethod.values[jint(json, 'CheckInMethod', 'checkInMethod').clamp(0, CheckInMethod.values.length - 1)],
      geofenceRadiusMeters: jintOrNull(json, 'GeofenceRadiusMeters', 'geofenceRadiusMeters'),
      requiresKycVerification: jbool(json, 'RequiresKycVerification', 'requiresKycVerification'),
      eventStartAt: jDateTime(json, 'EventStartAt', 'eventStartAt') ?? DateTime.now(),
      eventEndAt: jDateTime(json, 'EventEndAt', 'eventEndAt') ?? DateTime.now(),
      city: jstrOrNull(json, 'City', 'city'),
      country: jstrOrNull(json, 'Country', 'country'),
      latitude: jdoubleOrNull(json, 'Latitude', 'latitude'),
      longitude: jdoubleOrNull(json, 'Longitude', 'longitude'),
      isRemote: jbool(json, 'IsRemote', 'isRemote'),
      requiredSkills: jstringList(json, 'RequiredSkills', 'requiredSkills'),
      requiredDocuments: jstringList(json, 'RequiredDocuments', 'requiredDocuments'),
      registrationDeadline: jDateTime(json, 'RegistrationDeadline', 'registrationDeadline'),
      status: JobPostingStatus.values[jint(json, 'Status', 'status').clamp(0, JobPostingStatus.values.length - 1)],
      createdAt: jDateTime(json, 'CreatedAt', 'createdAt') ?? DateTime.now(),
    );
  }
}

class JobPostingSummaryModel {
  final String id;
  final String employerId;
  final String employerName;
  final String categoryName;
  final String title;
  final int capacity;
  final int acceptedCount;
  final double amount;
  final String currency;
  final PaymentType paymentType;
  final DateTime eventStartAt;
  final DateTime eventEndAt;
  final String? city;
  final String? country;
  final bool isRemote;
  final JobPostingStatus status;
  final DateTime createdAt;
  final double? distanceKm;

  const JobPostingSummaryModel({
    required this.id,
    required this.employerId,
    required this.employerName,
    required this.categoryName,
    required this.title,
    required this.capacity,
    required this.acceptedCount,
    required this.amount,
    required this.currency,
    required this.paymentType,
    required this.eventStartAt,
    required this.eventEndAt,
    this.city,
    this.country,
    required this.isRemote,
    required this.status,
    required this.createdAt,
    this.distanceKm,
  });

  int get remainingPlaces => (capacity - acceptedCount).clamp(0, capacity);

  factory JobPostingSummaryModel.fromJson(Map<String, dynamic> json) {
    return JobPostingSummaryModel(
      id: jstr(json, 'Id', 'id'),
      employerId: jstr(json, 'EmployerId', 'employerId'),
      employerName: jstr(json, 'EmployerName', 'employerName'),
      categoryName: jstr(json, 'CategoryName', 'categoryName'),
      title: jstr(json, 'Title', 'title'),
      capacity: jint(json, 'Capacity', 'capacity'),
      acceptedCount: jint(json, 'AcceptedCount', 'acceptedCount'),
      amount: jdouble(json, 'Amount', 'amount'),
      currency: jstr(json, 'Currency', 'currency'),
      paymentType: PaymentType.values[jint(json, 'PaymentType', 'paymentType').clamp(0, PaymentType.values.length - 1)],
      eventStartAt: jDateTime(json, 'EventStartAt', 'eventStartAt') ?? DateTime.now(),
      eventEndAt: jDateTime(json, 'EventEndAt', 'eventEndAt') ?? DateTime.now(),
      city: jstrOrNull(json, 'City', 'city'),
      country: jstrOrNull(json, 'Country', 'country'),
      isRemote: jbool(json, 'IsRemote', 'isRemote'),
      status: JobPostingStatus.values[jint(json, 'Status', 'status').clamp(0, JobPostingStatus.values.length - 1)],
      createdAt: jDateTime(json, 'CreatedAt', 'createdAt') ?? DateTime.now(),
      distanceKm: jdoubleOrNull(json, 'DistanceKm', 'distanceKm'),
    );
  }
}