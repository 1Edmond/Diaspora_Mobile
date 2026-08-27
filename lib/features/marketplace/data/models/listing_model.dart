import 'availability_slot_model.dart';
import '../../domain/entities/listing.dart';

class ListingModel {
  final String id;
  final String providerId;
  final String providerName;
  final String categoryId;
  final String categoryName;
  final String title;
  final String description;
  final String? contactInfo;
  final int paymentMode;
  final double? price;
  final String? currency;
  final int status;
  final bool isActive;
  final List<String> imageUrls;
  final double averageRating;
  final int reviewCount;
  final int viewCount;
  final DateTime createdAt;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final List<AvailabilitySlotModel> availabilitySlots;
  final bool isAvailableNow;
  final double? distanceKm;

  // Service-specific fields
  final ServiceCategory? serviceCategory;
  final PriceType? priceType;
  final ServiceScope? serviceScope;
  final List<String>? allowedDepartments;
  final bool isStandardService;

  const ListingModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.description,
    this.contactInfo,
    required this.paymentMode,
    this.price,
    this.currency,
    required this.status,
    required this.isActive,
    required this.imageUrls,
    required this.averageRating,
    required this.reviewCount,
    required this.viewCount,
    required this.createdAt,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    required this.availabilitySlots,
    required this.isAvailableNow,
    this.distanceKm,
    this.serviceCategory,
    this.priceType,
    this.serviceScope,
    this.allowedDepartments,
    this.isStandardService = false,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: _str(json, 'Id', 'id'),
      providerId: _str(json, 'ProviderId', 'providerId'),
      providerName: _str(json, 'ProviderName', 'providerName'),
      categoryId: _str(json, 'CategoryId', 'categoryId'),
      categoryName: _str(json, 'CategoryName', 'categoryName'),
      title: _str(json, 'Title', 'title'),
      description: _str(json, 'Description', 'description'),
      contactInfo: _strOrNull(json, 'ContactInfo', 'contactInfo'),
      paymentMode: _int(json, 'PaymentMode', 'paymentMode'),
      price: _double(json, 'Price', 'price'),
      currency: _strOrNull(json, 'Currency', 'currency'),
      status: _int(json, 'Status', 'status'),
      isActive: _bool(json, 'IsActive', 'isActive'),
      imageUrls: _stringList(json, 'ImageUrls', 'imageUrls'),
      averageRating: _doubleOrZero(json, 'AverageRating', 'averageRating'),
      reviewCount: _int(json, 'ReviewCount', 'reviewCount'),
      viewCount: _int(json, 'ViewCount', 'viewCount'),
      createdAt: _parseDateTime(json, 'CreatedAt', 'createdAt') ?? DateTime.now(),
      city: _strOrNull(json, 'City', 'city'),
      country: _strOrNull(json, 'Country', 'country'),
      latitude: _double(json, 'Latitude', 'latitude'),
      longitude: _double(json, 'Longitude', 'longitude'),
      availabilitySlots: _availabilitySlots(json),
      isAvailableNow: _bool(json, 'IsAvailableNow', 'isAvailableNow'),
      distanceKm: _double(json, 'DistanceKm', 'distanceKm'),
      serviceCategory: _parseServiceCategory(json),
      priceType: _parsePriceType(json),
      serviceScope: _parseServiceScope(json),
      allowedDepartments: _parseStringList(json, 'AllowedDepartments', 'allowedDepartments'),
      isStandardService: _bool(json, 'IsStandardService', 'isStandardService'),
    );
  }

  static ServiceCategory? _parseServiceCategory(Map<String, dynamic> json) {
    final raw = json['ServiceCategory'] ?? json['serviceCategory'] ?? json['Category'] ?? json['category'];
    if (raw == null) return null;
    if (raw is String) {
      try {
        return ServiceCategory.values.firstWhere(
          (e) => e.name.toLowerCase() == raw.toLowerCase(),
          orElse: () => ServiceCategory.other,
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static PriceType? _parsePriceType(Map<String, dynamic> json) {
    final raw = json['PriceType'] ?? json['priceType'];
    if (raw == null) return null;
    if (raw is String) {
      try {
        return PriceType.values.firstWhere(
          (e) => e.name.toLowerCase() == raw.toLowerCase(),
          orElse: () => PriceType.fixed,
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static ServiceScope? _parseServiceScope(Map<String, dynamic> json) {
    final raw = json['ServiceScope'] ?? json['serviceScope'] ?? json['Scope'] ?? json['scope'];
    if (raw == null) return null;
    if (raw is String) {
      try {
        return ServiceScope.values.firstWhere(
          (e) => e.name.toLowerCase() == raw.toLowerCase(),
          orElse: () => ServiceScope.cityOnly,
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static String _str(Map<String, dynamic> json, String pascal, String camel) {
    return (json[pascal] ?? json[camel] ?? '') as String;
  }

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

  static double? _double(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return null;
    return (val as num).toDouble();
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
    final val = json[pascal] ?? json[camel];
    if (val == null) return [];
    if (val is List) return val.map((e) => e.toString()).toList();
    return [];
  }

  static List<String> _parseStringList(Map<String, dynamic> json, String pascal, String camel) {
    final raw = json[pascal] ?? json[camel];
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  static List<AvailabilitySlotModel> _availabilitySlots(Map<String, dynamic> json) {
    final raw = json['AvailabilitySlots'] ?? json['availabilitySlots'];
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((e) => AvailabilitySlotModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static DateTime? _parseDateTime(Map<String, dynamic> json, String pascal, String camel) {
    final raw = json[pascal] ?? json[camel];
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'ProviderId': providerId,
    'ProviderName': providerName,
    'CategoryId': categoryId,
    'CategoryName': categoryName,
    'Title': title,
    'Description': description,
    'ContactInfo': contactInfo,
    'PaymentMode': paymentMode,
    'Price': price,
    'Currency': currency,
    'Status': status,
    'IsActive': isActive,
    'ImageUrls': imageUrls,
    'AverageRating': averageRating,
    'ReviewCount': reviewCount,
    'ViewCount': viewCount,
    'CreatedAt': createdAt.toIso8601String(),
    'City': city,
    'Country': country,
    'Latitude': latitude,
    'Longitude': longitude,
    'AvailabilitySlots': availabilitySlots.map((e) => e.toJson()).toList(),
    'IsAvailableNow': isAvailableNow,
    'DistanceKm': distanceKm,
    'ServiceCategory': serviceCategory?.name,
    'PriceType': priceType?.name,
    'ServiceScope': serviceScope?.name,
    'AllowedDepartments': allowedDepartments,
    'IsStandardService': isStandardService,
  };
}