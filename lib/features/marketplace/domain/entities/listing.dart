import 'package:flutter/material.dart';
import 'availability_slot.dart';

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
    );
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
}