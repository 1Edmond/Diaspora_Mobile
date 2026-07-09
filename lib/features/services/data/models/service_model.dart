import '../../domain/entities/service.dart';

class ServiceModel extends Service {
  const ServiceModel({
    required super.id,
    required super.providerId,
    required super.title,
    required super.description,
    required super.price,
    required super.currency,
    required super.priceType,
    super.category = ServiceCategory.OTHER,
    required super.images,
    required super.scope,
    super.allowedDepartments,
    required super.rating,
    required super.reviewCount,
    required super.status,
    required super.createdAt,
  });
  // Factory to convert from base Entity to Model
  factory ServiceModel.fromEntity(Service service) {
    if (service is ServiceModel) return service;
    return ServiceModel(
      id: service.id,
      providerId: service.providerId,
      title: service.title,
      description: service.description,
      price: service.price,
      currency: service.currency,
      priceType: service.priceType,
      category: service.category,
      images: service.images,
      scope: service.scope,
      allowedDepartments: service.allowedDepartments,
      rating: service.rating,
      reviewCount: service.reviewCount,
      status: service.status,
      createdAt: service.createdAt,
    );
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      providerId: json['providerId'] as String? ?? 'unknown',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'XOF',
      priceType: PriceType.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['priceType'] as String? ?? 'FIXED'),
      ),
      category: ServiceCategory.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['category'] as String? ?? 'OTHER'),
        orElse: () => ServiceCategory.OTHER,
      ),
      images: List<String>.from(json['images'] ?? []),
      scope: ServiceScope.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['scope'] as String? ?? 'CITY_ONLY'),
      ),
      allowedDepartments:
          json['allowedDepartments'] != null
              ? List<String>.from(json['allowedDepartments'])
              : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      status: json['status'] as String? ?? 'PENDING',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'providerId': providerId,
    'title': title,
    'description': description,
    'price': price,
    'currency': currency,
    'priceType': priceType.toString().split('.').last,
    'category': category.toString().split('.').last,
    'images': images,
    'scope': scope.toString().split('.').last,
    'allowedDepartments': allowedDepartments,
    'rating': rating,
    'reviewCount': reviewCount,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };
}
