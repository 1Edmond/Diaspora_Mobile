import 'availability_slot_model.dart';
import '../../domain/entities/listing.dart';
import '../../domain/entities/enums.dart';

class CreateListingDto {
  final String categoryId;
  final String title;
  final String description;
  final String? contactInfo;
  final int paymentMode;
  final double? price;
  final String? currency;
  final List<String> imagePaths;
  final List<AvailabilitySlotModel> availabilitySlots;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;

  // Service-specific fields
  final ServiceCategory? serviceCategory;
  final PriceType? priceType;
  final ServiceScope? serviceScope;
  final List<String>? allowedDepartments;
  final bool isStandardService;

  // Travel fields
  final String? departureCountryCode;
  final String? departureCity;
  final String? arrivalCountryCode;
  final String? arrivalCity;
  final DateTime? departureDate;
  final DateTime? arrivalDate;
  final DateTime? pickupDeadline;
  final double? capacityKg;
  final double? remainingKg;
  final double? pricePerKg;
  final String? transportMode;
  final String? prohibitedItemsDescription;

  const CreateListingDto({
    required this.categoryId,
    required this.title,
    required this.description,
    this.contactInfo,
    required this.paymentMode,
    this.price,
    this.currency,
    required this.imagePaths,
    required this.availabilitySlots,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    this.serviceCategory,
    this.priceType,
    this.serviceScope,
    this.allowedDepartments,
    this.isStandardService = false,
    this.departureCountryCode,
    this.departureCity,
    this.arrivalCountryCode,
    this.arrivalCity,
    this.departureDate,
    this.arrivalDate,
    this.pickupDeadline,
    this.capacityKg,
    this.remainingKg,
    this.pricePerKg,
    this.transportMode,
    this.prohibitedItemsDescription,
  });

  Map<String, dynamic> toJson() => {
    'CategoryId': categoryId,
    'Title': title,
    'Description': description,
    'ContactInfo': contactInfo,
    'PaymentMode': paymentMode,
    'Price': price,
    'Currency': currency,
    'ImagePaths': imagePaths,
    'AvailabilitySlots': availabilitySlots.map((e) => e.toJson()).toList(),
    'Latitude': latitude,
    'Longitude': longitude,
    'City': city,
    'Country': country,
    'ServiceCategory': serviceCategory?.name,
    'PriceType': priceType?.name,
    'ServiceScope': serviceScope?.name,
    'AllowedDepartments': allowedDepartments,
    'IsStandardService': isStandardService,
    'DepartureCountryCode': departureCountryCode,
    'DepartureCity': departureCity,
    'ArrivalCountryCode': arrivalCountryCode,
    'ArrivalCity': arrivalCity,
    'DepartureDate': departureDate?.toIso8601String(),
    'ArrivalDate': arrivalDate?.toIso8601String(),
    'PickupDeadline': pickupDeadline?.toIso8601String(),
    'CapacityKg': capacityKg,
    'RemainingKg': remainingKg,
    'PricePerKg': pricePerKg,
    'TransportMode': transportMode,
    'ProhibitedItemsDescription': prohibitedItemsDescription,
  };
}

class UpdateListingDto {
  final String? title;
  final String? description;
  final String? contactInfo;
  final int? paymentMode;
  final double? price;
  final String? currency;
  final List<String>? imagePaths;
  final List<AvailabilitySlotModel>? availabilitySlots;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;

  // Service-specific fields
  final ServiceCategory? serviceCategory;
  final PriceType? priceType;
  final ServiceScope? serviceScope;
  final List<String>? allowedDepartments;
  final bool? isStandardService;

  // Travel fields
  final String? departureCountryCode;
  final String? departureCity;
  final String? arrivalCountryCode;
  final String? arrivalCity;
  final DateTime? departureDate;
  final DateTime? arrivalDate;
  final DateTime? pickupDeadline;
  final double? capacityKg;
  final double? remainingKg;
  final double? pricePerKg;
  final String? transportMode;
  final String? prohibitedItemsDescription;

  const UpdateListingDto({
    this.title,
    this.description,
    this.contactInfo,
    this.paymentMode,
    this.price,
    this.currency,
    this.imagePaths,
    this.availabilitySlots,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    this.serviceCategory,
    this.priceType,
    this.serviceScope,
    this.allowedDepartments,
    this.isStandardService,
    this.departureCountryCode,
    this.departureCity,
    this.arrivalCountryCode,
    this.arrivalCity,
    this.departureDate,
    this.arrivalDate,
    this.pickupDeadline,
    this.capacityKg,
    this.remainingKg,
    this.pricePerKg,
    this.transportMode,
    this.prohibitedItemsDescription,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['Title'] = title;
    if (description != null) map['Description'] = description;
    if (contactInfo != null) map['ContactInfo'] = contactInfo;
    if (paymentMode != null) map['PaymentMode'] = paymentMode;
    if (price != null) map['Price'] = price;
    if (currency != null) map['Currency'] = currency;
    if (imagePaths != null) map['ImagePaths'] = imagePaths;
    if (availabilitySlots != null) {
      map['AvailabilitySlots'] = availabilitySlots!.map((e) => e.toJson()).toList();
    }
    if (latitude != null) map['Latitude'] = latitude;
    if (longitude != null) map['Longitude'] = longitude;
    if (city != null) map['City'] = city;
    if (country != null) map['Country'] = country;
    if (serviceCategory != null) map['ServiceCategory'] = serviceCategory!.name;
    if (priceType != null) map['PriceType'] = priceType!.name;
    if (serviceScope != null) map['ServiceScope'] = serviceScope!.name;
    if (allowedDepartments != null) map['AllowedDepartments'] = allowedDepartments;
    if (isStandardService != null) map['IsStandardService'] = isStandardService;
    if (departureCountryCode != null) map['DepartureCountryCode'] = departureCountryCode;
    if (departureCity != null) map['DepartureCity'] = departureCity;
    if (arrivalCountryCode != null) map['ArrivalCountryCode'] = arrivalCountryCode;
    if (arrivalCity != null) map['ArrivalCity'] = arrivalCity;
    if (departureDate != null) map['DepartureDate'] = departureDate!.toIso8601String();
    if (arrivalDate != null) map['ArrivalDate'] = arrivalDate!.toIso8601String();
    if (pickupDeadline != null) map['PickupDeadline'] = pickupDeadline!.toIso8601String();
    if (capacityKg != null) map['CapacityKg'] = capacityKg;
    if (remainingKg != null) map['RemainingKg'] = remainingKg;
    if (pricePerKg != null) map['PricePerKg'] = pricePerKg;
    if (transportMode != null) map['TransportMode'] = transportMode;
    if (prohibitedItemsDescription != null) map['ProhibitedItemsDescription'] = prohibitedItemsDescription;
    return map;
  }
}

class CreateReviewDto {
  final int rating;
  final String comment;

  const CreateReviewDto({
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() => {
    'Rating': rating,
    'Comment': comment,
  };
}

class UpdateReviewDto {
  final int? rating;
  final String? comment;

  const UpdateReviewDto({
    this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (rating != null) map['Rating'] = rating;
    if (comment != null) map['Comment'] = comment;
    return map;
  }
}

class CreateServiceRequestDto {
  final String listingId;
  final String message;
  final double? weightKg;
  final double? declaredValue;
  final String? packageContentCategory;
  final String? packageDescription;
  final double? agreedPrice;
  final String? agreedCurrency;
  final PaymentSettlementType? settlementType;
  final DirectCashTiming? cashTiming;
  final double? platformDirectFeeAmount;

  const CreateServiceRequestDto({
    required this.listingId,
    required this.message,
    this.weightKg,
    this.declaredValue,
    this.packageContentCategory,
    this.packageDescription,
    this.agreedPrice,
    this.agreedCurrency,
    this.settlementType,
    this.cashTiming,
    this.platformDirectFeeAmount,
  });

  Map<String, dynamic> toJson() => {
    'ListingId': listingId,
    'Message': message,
    if (weightKg != null) 'WeightKg': weightKg,
    if (declaredValue != null) 'DeclaredValue': declaredValue,
    if (packageContentCategory != null)
      'PackageContentCategory': packageContentCategory,
    if (packageDescription != null) 'PackageDescription': packageDescription,
    if (agreedPrice != null) 'AgreedPrice': agreedPrice,
    if (agreedCurrency != null) 'AgreedCurrency': agreedCurrency,
    if (settlementType != null) 'SettlementType': settlementType!.index,
    if (cashTiming != null) 'CashTiming': cashTiming!.index,
    if (platformDirectFeeAmount != null) 'PlatformDirectFeeAmount': platformDirectFeeAmount,
  };
}

class CreateReportDto {
  final int targetType;
  final String targetId;
  final String reason;

  const CreateReportDto({
    required this.targetType,
    required this.targetId,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'TargetType': targetType,
    'TargetId': targetId,
    'Reason': reason,
  };
}

class BookParcelDto {
  final String listingId;
  final double weightKg;
  final String parcelNature;
  final double declaredValue;
  final String currency;
  final String? message;
  final PaymentSettlementType? settlementType;
  final DirectCashTiming? cashTiming;
  final double? platformDirectFeeAmount;

  const BookParcelDto({
    required this.listingId,
    required this.weightKg,
    required this.parcelNature,
    required this.declaredValue,
    required this.currency,
    this.message,
    this.settlementType,
    this.cashTiming,
    this.platformDirectFeeAmount,
  });

  Map<String, dynamic> toJson() => {
    'ListingId': listingId,
    'WeightKg': weightKg,
    'ParcelNature': parcelNature,
    'DeclaredValue': declaredValue,
    'Currency': currency,
    'Message': message ?? '',
    if (settlementType != null) 'SettlementType': settlementType!.index,
    if (cashTiming != null) 'CashTiming': cashTiming!.index,
    if (platformDirectFeeAmount != null) 'PlatformDirectFeeAmount': platformDirectFeeAmount,
  };
}