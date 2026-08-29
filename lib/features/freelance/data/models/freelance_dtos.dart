class CreateJobTemplateDto {
  final String name;
  final String? description;
  final String categoryId;
  final List<String> requiredSkills;
  final List<String> requiredDocuments;
  final int defaultCapacity;
  final double defaultAmount;
  final String defaultCurrency;
  final int defaultPaymentType;
  final int defaultPaymentTiming;
  final int defaultCheckInMethod;
  final int? defaultGeofenceRadiusMeters;
  final bool defaultRequiresKyc;

  const CreateJobTemplateDto({
    required this.name,
    this.description,
    required this.categoryId,
    this.requiredSkills = const [],
    this.requiredDocuments = const [],
    required this.defaultCapacity,
    required this.defaultAmount,
    required this.defaultCurrency,
    required this.defaultPaymentType,
    required this.defaultPaymentTiming,
    required this.defaultCheckInMethod,
    this.defaultGeofenceRadiusMeters,
    required this.defaultRequiresKyc,
  });

  Map<String, dynamic> toJson() => {
    'Name': name,
    'Description': description,
    'CategoryId': categoryId,
    'RequiredSkills': requiredSkills,
    'RequiredDocuments': requiredDocuments,
    'DefaultCapacity': defaultCapacity,
    'DefaultAmount': defaultAmount,
    'DefaultCurrency': defaultCurrency,
    'DefaultPaymentType': defaultPaymentType,
    'DefaultPaymentTiming': defaultPaymentTiming,
    'DefaultCheckInMethod': defaultCheckInMethod,
    'DefaultGeofenceRadiusMeters': defaultGeofenceRadiusMeters,
    'DefaultRequiresKyc': defaultRequiresKyc,
  };
}

class CreateJobPostingDto {
  final String? templateId;
  final String categoryId;
  final String title;
  final String description;
  final int capacity;
  final double amount;
  final String currency;
  final int paymentType;
  final int paymentTiming;
  final int checkInMethod;
  final int? geofenceRadiusMeters;
  final bool requiresKycVerification;
  final String eventStartAt;
  final String eventEndAt;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final bool isRemote;
  final List<String> requiredSkills;
  final List<String> requiredDocuments;
  final String? registrationDeadline;

  const CreateJobPostingDto({
    this.templateId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.capacity,
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
    this.requiredSkills = const [],
    this.requiredDocuments = const [],
    this.registrationDeadline,
  });

  Map<String, dynamic> toJson() => {
    if (templateId != null) 'TemplateId': templateId,
    'CategoryId': categoryId,
    'Title': title,
    'Description': description,
    'Capacity': capacity,
    'Amount': amount,
    'Currency': currency,
    'PaymentType': paymentType,
    'PaymentTiming': paymentTiming,
    'CheckInMethod': checkInMethod,
    'GeofenceRadiusMeters': geofenceRadiusMeters,
    'RequiresKycVerification': requiresKycVerification,
    'EventStartAt': eventStartAt,
    'EventEndAt': eventEndAt,
    'City': city,
    'Country': country,
    'Latitude': latitude,
    'Longitude': longitude,
    'IsRemote': isRemote,
    'RequiredSkills': requiredSkills,
    'RequiredDocuments': requiredDocuments,
    'RegistrationDeadline': registrationDeadline,
  };
}

class UpdateJobPostingDto {
  final String? templateId;
  final String? categoryId;
  final String? title;
  final String? description;
  final int? capacity;
  final double? amount;
  final String? currency;
  final int? paymentType;
  final int? paymentTiming;
  final int? checkInMethod;
  final int? geofenceRadiusMeters;
  final bool? requiresKycVerification;
  final String? eventStartAt;
  final String? eventEndAt;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final bool? isRemote;
  final List<String>? requiredSkills;
  final List<String>? requiredDocuments;
  final String? registrationDeadline;

  const UpdateJobPostingDto({
    this.templateId,
    this.categoryId,
    this.title,
    this.description,
    this.capacity,
    this.amount,
    this.currency,
    this.paymentType,
    this.paymentTiming,
    this.checkInMethod,
    this.geofenceRadiusMeters,
    this.requiresKycVerification,
    this.eventStartAt,
    this.eventEndAt,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.isRemote,
    this.requiredSkills,
    this.requiredDocuments,
    this.registrationDeadline,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    void put(String key, dynamic value) {
      if (value != null) map[key] = value;
    }

    put('TemplateId', templateId);
    put('CategoryId', categoryId);
    put('Title', title);
    put('Description', description);
    put('Capacity', capacity);
    put('Amount', amount);
    put('Currency', currency);
    put('PaymentType', paymentType);
    put('PaymentTiming', paymentTiming);
    put('CheckInMethod', checkInMethod);
    put('GeofenceRadiusMeters', geofenceRadiusMeters);
    put('RequiresKycVerification', requiresKycVerification);
    put('EventStartAt', eventStartAt);
    put('EventEndAt', eventEndAt);
    put('City', city);
    put('Country', country);
    put('Latitude', latitude);
    put('Longitude', longitude);
    put('IsRemote', isRemote);
    put('RequiredSkills', requiredSkills);
    put('RequiredDocuments', requiredDocuments);
    put('RegistrationDeadline', registrationDeadline);
    return map;
  }
}

class ApplyToJobDto {
  final String? message;

  const ApplyToJobDto({this.message});

  Map<String, dynamic> toJson() => {
    if (message != null) 'Message': message,
  };
}

class CreateJobCheckInDto {
  final int method;
  final double? latitude;
  final double? longitude;

  const CreateJobCheckInDto({
    required this.method,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'Method': method,
    'Latitude': latitude,
    'Longitude': longitude,
  };
}

class CreateJobReviewDto {
  final int raterRole;
  final int punctualityScore;
  final int qualityScore;
  final int communicationScore;
  final String? comment;

  const CreateJobReviewDto({
    required this.raterRole,
    required this.punctualityScore,
    required this.qualityScore,
    required this.communicationScore,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
    'RaterRole': raterRole,
    'PunctualityScore': punctualityScore,
    'QualityScore': qualityScore,
    'CommunicationScore': communicationScore,
    'Comment': comment,
  };
}

class CreateJobPreferenceDto {
  final String categoryId;
  final String? city;
  final double? maxDistanceKm;

  const CreateJobPreferenceDto({
    required this.categoryId,
    this.city,
    this.maxDistanceKm,
  });

  Map<String, dynamic> toJson() => {
    'CategoryId': categoryId,
    'City': city,
    'MaxDistanceKm': maxDistanceKm,
  };
}