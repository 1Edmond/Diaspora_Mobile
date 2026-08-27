import 'package:flutter/material.dart';
import 'availability_slot.dart';

enum ServiceCategory {
  housing,
  transport,
  translation,
  administrativeHelp,
  groceries,
  tutoring,
  cleaning,
  repair,
  other,
}

enum PriceType { fixed, perHour, negotiable }

enum ServiceScope { cityOnly, departmentList, countryWide }

class Listing {
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
  final List<AvailabilitySlot> availabilitySlots;
  final bool isAvailableNow;
  final double? distanceKm;

  // Service-specific fields (optional - for unified marketplace/service model)
  final ServiceCategory? serviceCategory;
  final PriceType? priceType;
  final ServiceScope? serviceScope;
  final List<String>? allowedDepartments;
  final bool isStandardService;

  const Listing({
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

  Listing copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? categoryId,
    String? categoryName,
    String? title,
    String? description,
    String? contactInfo,
    int? paymentMode,
    double? price,
    String? currency,
    int? status,
    bool? isActive,
    List<String>? imageUrls,
    double? averageRating,
    int? reviewCount,
    int? viewCount,
    DateTime? createdAt,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    List<AvailabilitySlot>? availabilitySlots,
    bool? isAvailableNow,
    double? distanceKm,
    ServiceCategory? serviceCategory,
    PriceType? priceType,
    ServiceScope? serviceScope,
    List<String>? allowedDepartments,
    bool? isStandardService,
  }) {
    return Listing(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      title: title ?? this.title,
      description: description ?? this.description,
      contactInfo: contactInfo ?? this.contactInfo,
      paymentMode: paymentMode ?? this.paymentMode,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      imageUrls: imageUrls ?? this.imageUrls,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      availabilitySlots: availabilitySlots ?? this.availabilitySlots,
      isAvailableNow: isAvailableNow ?? this.isAvailableNow,
      distanceKm: distanceKm ?? this.distanceKm,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      priceType: priceType ?? this.priceType,
      serviceScope: serviceScope ?? this.serviceScope,
      allowedDepartments: allowedDepartments ?? this.allowedDepartments,
      isStandardService: isStandardService ?? this.isStandardService,
    );
  }

  factory Listing.fromService({
    required String id,
    required String providerId,
    required String providerName,
    required String title,
    required String description,
    required double price,
    required String currency,
    required PriceType priceType,
    required ServiceCategory category,
    required List<String> images,
    required ServiceScope scope,
    List<String>? allowedDepartments,
    required double rating,
    required int reviewCount,
    required String status,
    required DateTime createdAt,
    String? city,
    String? country,
  }) {
    return Listing(
      id: id,
      providerId: providerId,
      providerName: providerName,
      categoryId: category.name.toLowerCase(),
      categoryName: _categoryDisplayName(category),
      title: title,
      description: description,
      paymentMode: _priceTypeToPaymentMode(priceType),
      price: price,
      currency: currency,
      status: _statusToInt(status),
      isActive: status.toUpperCase() == 'ACTIVE' || status.toUpperCase() == 'APPROVED',
      imageUrls: images,
      averageRating: rating,
      reviewCount: reviewCount,
      viewCount: 0,
      createdAt: createdAt,
      city: city,
      country: country,
      availabilitySlots: [],
      isAvailableNow: true,
      serviceCategory: category,
      priceType: priceType,
      serviceScope: scope,
      allowedDepartments: allowedDepartments,
      isStandardService: true,
    );
  }

  static int _priceTypeToPaymentMode(PriceType type) {
    switch (type) {
      case PriceType.fixed:
        return 1;
      case PriceType.perHour:
        return 1;
      case PriceType.negotiable:
        return 2;
    }
  }

  static int _statusToInt(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 0;
      case 'ACTIVE':
      case 'APPROVED':
        return 1;
      case 'REJECTED':
        return 2;
      case 'SUSPENDED':
        return 3;
      default:
        return 0;
    }
  }

  static String _categoryDisplayName(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.housing:
        return 'Logement';
      case ServiceCategory.transport:
        return 'Transport';
      case ServiceCategory.translation:
        return 'Traduction';
      case ServiceCategory.administrativeHelp:
        return 'Aide administrative';
      case ServiceCategory.groceries:
        return 'Courses';
      case ServiceCategory.tutoring:
        return 'Soutien scolaire';
      case ServiceCategory.cleaning:
        return 'Ménage';
      case ServiceCategory.repair:
        return 'Réparation';
      case ServiceCategory.other:
        return 'Autre';
    }
  }

  String getFormattedPrice(BuildContext context) {
    if (price == null) return 'Prix sur demande';
    final formatted = price!.toStringAsFixed(price! == price!.toInt() ? 0 : 2);
    return '$formatted ${currency ?? "XOF"}';
  }

  String getFormattedDistance(BuildContext context) {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).round()} m';
    }
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  String getAvailabilityDisplayString(BuildContext context) {
    if (availabilitySlots.isEmpty) return 'Disponibilités non définies';
    final slots = availabilitySlots.where((s) => s.isValid).toList();
    if (slots.isEmpty) return 'Disponibilités non valides';

    final byDay = <int, List<AvailabilitySlot>>{};
    for (final slot in slots) {
      byDay.putIfAbsent(slot.day, () => []).add(slot);
    }

    final daysWithSlots = byDay.keys.toList()..sort();
    if (daysWithSlots.length == 7 &&
        byDay.values.every((list) => list.length == 1 &&
            list.first.startTime == '00:00:00' &&
            list.first.endTime == '23:59:59')) {
      return 'Disponible 7j/7';
    }

    return daysWithSlots
        .map((day) {
          final slot = byDay[day]!.first;
          return '${slot.getShortDayName(context)} ${slot.getFormattedTime(slot.startTime)}-${slot.getFormattedTime(slot.endTime)}';
        })
        .join(', ');
  }

  Color getStatusColor(BuildContext context) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      case 3:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String getStatusLabel(BuildContext context) {
    switch (status) {
      case 0:
        return 'En attente';
      case 1:
        return 'Approuvé';
      case 2:
        return 'Rejeté';
      case 3:
        return 'Suspendu';
      default:
        return 'Inconnu';
    }
  }

  bool get isApproved => status == 1;
  bool get isPending => status == 0;
  bool get isRejected => status == 2;
  bool get isSuspended => status == 3;

  String getProviderDisplayName() {
    return providerName.trim().isNotEmpty ? providerName : 'Prestataire';
  }

  String getPriceTypeLabel() {
    if (!isStandardService || priceType == null) return '';
    switch (priceType!) {
      case PriceType.fixed:
        return 'Prix fixe';
      case PriceType.perHour:
        return 'Par heure';
      case PriceType.negotiable:
        return 'Négociable';
    }
  }

  String getServiceScopeLabel() {
    if (!isStandardService || serviceScope == null) return '';
    switch (serviceScope!) {
      case ServiceScope.cityOnly:
        return 'Ville uniquement';
      case ServiceScope.departmentList:
        return 'Départements sélectionnés';
      case ServiceScope.countryWide:
        return 'Tout le pays';
    }
  }
}