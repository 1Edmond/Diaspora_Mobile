import 'availability_slot_model.dart';
import '../../domain/entities/listing.dart';

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

  const CreateServiceRequestDto({
    required this.listingId,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
    'ListingId': listingId,
    'Message': message,
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