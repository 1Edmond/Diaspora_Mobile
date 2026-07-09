import 'package:flutter/foundation.dart';

enum ServiceCategory {
  HOUSING,
  TRANSPORT,
  TRANSLATION,
  ADMINISTRATIVE_HELP,
  GROCERIES,
  TUTORING,
  CLEANING,
  REPAIR,
  OTHER,
}

enum PriceType { FIXED, PER_HOUR, NEGOTIABLE }

enum ServiceScope { CITY_ONLY, DEPARTMENT_LIST, COUNTRY_WIDE }

@immutable
class Service {
  final String id;
  final String providerId;
  final String title;
  final String description;
  final double price;
  final String currency;
  final PriceType priceType;
  final List<String> images;
  final ServiceScope scope;
  final List<String>? allowedDepartments;
  final double rating;
  final int reviewCount;
  final String status; // PENDING, APPROVED, REJECTED, ACTIVE, INACTIVE
  final DateTime createdAt;

  const Service({
    required this.id,
    required this.providerId,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.priceType,
    required this.images,
    required this.scope,
    this.allowedDepartments,
    required this.rating,
    required this.reviewCount,
    required this.status,
    required this.createdAt,
  });
}
