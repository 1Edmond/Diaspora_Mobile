import '../../domain/entities/listing.dart';

class ListingSummaryModel {
  final String id;
  final String providerId;
  final String providerName;
  final String categoryName;
  final String title;
  final int paymentMode;
  final double? price;
  final String? currency;
  final double averageRating;
  final int reviewCount;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final String? city;
  final String? country;
  final double? distanceKm;
  final int status;

  // Service-specific fields
  final ServiceCategory? serviceCategory;
  final PriceType? priceType;
  final ServiceScope? serviceScope;
  final List<String>? allowedDepartments;
  final bool isStandardService;

  const ListingSummaryModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.categoryName,
    required this.title,
    required this.paymentMode,
    this.price,
    this.currency,
    required this.averageRating,
    required this.reviewCount,
    this.thumbnailUrl,
    required this.createdAt,
    this.city,
    this.country,
    this.distanceKm,
    this.status = 0,
    this.serviceCategory,
    this.priceType,
    this.serviceScope,
    this.allowedDepartments,
    this.isStandardService = false,
  });

  factory ListingSummaryModel.fromJson(Map<String, dynamic> json) {
    return ListingSummaryModel(
      id: _str(json, 'Id', 'id'),
      providerId: _str(json, 'ProviderId', 'providerId'),
      providerName: _str(json, 'ProviderName', 'providerName'),
      categoryName: _str(json, 'CategoryName', 'categoryName'),
      title: _str(json, 'Title', 'title'),
      paymentMode: _int(json, 'PaymentMode', 'paymentMode'),
      price: _doubleOrZero(json, 'Price', 'price'),
      currency: _strOrNull(json, 'Currency', 'currency'),
      averageRating: _doubleOrZero(json, 'AverageRating', 'averageRating'),
      reviewCount: _int(json, 'ReviewCount', 'reviewCount'),
      thumbnailUrl: _strOrNull(json, 'ThumbnailUrl', 'thumbnailUrl'),
      createdAt: _parseDateTime(json, 'CreatedAt', 'createdAt') ?? DateTime.now(),
      city: _strOrNull(json, 'City', 'city'),
      country: _strOrNull(json, 'Country', 'country'),
      distanceKm: _double(json, 'DistanceKm', 'distanceKm'),
      status: _int(json, 'Status', 'status'),
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

  static List<String> _parseStringList(Map<String, dynamic> json, String pascal, String camel) {
    final raw = json[pascal] ?? json[camel];
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  static DateTime? _parseDateTime(Map<String, dynamic> json, String pascal, String camel) {
    final raw = json[pascal] ?? json[camel];
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    return null;
  }
}