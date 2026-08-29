import 'dart:ui';

import '../../../../core/constants/enums.dart';

class Profile {
  final String id;
  final String userId;
  final String profileType;
  final String profileTypeId;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final ProfileStatus status;
  final DateTime createdAt;

  final DateTime? dateOfBirth;
  final DateTime? verifiedAt;
  final String? verifiedByAdminId;

  final String? country;
  final String? universityOrCompany;
  final String? localAddress;
  final String? localPhoneNumber;
  final DateTime? arrivalDate;
  final Color? profileColor;

  String get fullName => '$firstName $lastName';

  bool get isInternal => profileType == 'Internal';
  bool get isExternal => profileType == 'External';

  Color get effectiveColor {
    if (profileColor != null) return profileColor!;
    return isInternal
        ? const Color(0xFF0033A0)
        : const Color(0xFF006B3F);
  }

  /// Short label describing what this profile is set up for. Prefers the
  /// user-entered organization/company (e.g. "Université de Lomé"); falls
  /// back to the technical Interne/Externe type when no organization was
  /// provided, since that's the only other classification the data model
  /// currently carries.
  String get displaySubtitle {
    if (universityOrCompany != null && universityOrCompany!.trim().isNotEmpty) {
      return universityOrCompany!;
    }
    return isInternal ? 'Interne' : 'Externe';
  }

  bool get isPending => status == ProfileStatus.PENDING;
  bool get isRejected => status == ProfileStatus.REJECTED;
  bool get isValidated => status == ProfileStatus.VALIDATED;

  /// Short label for the profile's validation state, shown as a badge.
  String? get statusLabel {
    switch (status) {
      case ProfileStatus.PENDING:
        return 'En attente';
      case ProfileStatus.REJECTED:
        return 'Rejeté';
      case ProfileStatus.VALIDATED:
        return null; // validated is the default state, no badge needed
    }
  }

  /// Color associated with the profile's validation state (used for the
  /// small status dot and badge background).
  Color get statusColor {
    switch (status) {
      case ProfileStatus.PENDING:
        return const Color(0xFFF59E0B); // amber
      case ProfileStatus.REJECTED:
        return const Color(0xFFDC2626); // red
      case ProfileStatus.VALIDATED:
        return const Color(0xFF16A34A); // green
    }
  }

  Profile({
    required this.id,
    required this.userId,
    required this.profileType,
    required this.profileTypeId,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.status,
    required this.createdAt,
    this.dateOfBirth,
    this.verifiedAt,
    this.verifiedByAdminId,
    this.country,
    this.universityOrCompany,
    this.localAddress,
    this.localPhoneNumber,
    this.arrivalDate,
    this.profileColor,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['Id'] as String? ?? json['id'] as String? ?? '',
      userId: json['UserId'] as String? ?? json['userId'] as String? ?? '',
      profileType:
          json['ProfileType'] as String? ??
          json['profileType'] as String? ??
          'Internal',
      profileTypeId:
          json['ProfileTypeId'] as String? ??
          json['profileTypeId'] as String? ??
          '',
      firstName:
          json['FirstName'] as String? ?? json['firstName'] as String? ?? '',
      lastName:
          json['LastName'] as String? ?? json['lastName'] as String? ?? '',
      phoneNumber:
          json['PhoneNumber'] as String? ?? json['phoneNumber'] as String?,
      status: json['Status'] != null
          ? _parseStatus(json['Status'])
          : json['status'] != null
              ? _parseStatus(json['status'])
              : ProfileStatus.PENDING,
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      dateOfBirth: json['DateOfBirth'] != null
          ? DateTime.parse(json['DateOfBirth'] as String)
          : json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'] as String)
              : null,
      verifiedAt: json['VerifiedAt'] != null
          ? DateTime.parse(json['VerifiedAt'] as String)
          : json['verifiedAt'] != null
              ? DateTime.parse(json['verifiedAt'] as String)
              : null,
      verifiedByAdminId:
          json['VerifiedByAdminId'] as String? ??
          json['verifiedByAdminId'] as String?,
      country: json['Country'] as String? ?? json['country'] as String?,
      universityOrCompany:
          json['UniversityOrCompany'] as String? ??
          json['universityOrCompany'] as String?,
      localAddress:
          json['LocalAddress'] as String? ?? json['localAddress'] as String?,
      localPhoneNumber:
          json['LocalPhoneNumber'] as String? ??
          json['localPhoneNumber'] as String?,
      arrivalDate: json['ArrivalDate'] != null
          ? DateTime.parse(json['ArrivalDate'] as String)
          : json['arrivalDate'] != null
              ? DateTime.parse(json['arrivalDate'] as String)
              : null,
      profileColor: _parseColor(
        json['ProfileColor'] as String? ?? json['profileColor'] as String?,
      ),
    );
  }

  static Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceFirst('#', '');
    if (cleaned.length != 6 && cleaned.length != 8) return null;
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  static ProfileStatus _parseStatus(dynamic val) {
    if (val == 'VALIDATED' || val == 'Active' || val == 1) {
      return ProfileStatus.VALIDATED;
    }
    if (val == 'REJECTED' || val == 2) return ProfileStatus.REJECTED;
    return ProfileStatus.PENDING;
  }

  Profile copyWith({
    String? id,
    String? userId,
    String? profileType,
    String? profileTypeId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    ProfileStatus? status,
    DateTime? createdAt,
    DateTime? dateOfBirth,
    DateTime? verifiedAt,
    String? verifiedByAdminId,
    String? country,
    String? universityOrCompany,
    String? localAddress,
    String? localPhoneNumber,
    DateTime? arrivalDate,
    Color? profileColor,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profileType: profileType ?? this.profileType,
      profileTypeId: profileTypeId ?? this.profileTypeId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedByAdminId: verifiedByAdminId ?? this.verifiedByAdminId,
      country: country ?? this.country,
      universityOrCompany: universityOrCompany ?? this.universityOrCompany,
      localAddress: localAddress ?? this.localAddress,
      localPhoneNumber: localPhoneNumber ?? this.localPhoneNumber,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      profileColor: profileColor ?? this.profileColor,
    );
  }
}
