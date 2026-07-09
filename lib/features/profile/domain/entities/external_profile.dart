import 'package:diaspora_app/core/constants/enums.dart';
import 'digital_passport.dart';

class ExternalProfile {
  final String id;
  final String userId;
  final String country;
  final String departmentId;
  final String universityOrCompany;
  final String localAddress;
  final String localPhoneNumber;
  final DateTime arrivalDate;
  final UserType userType;
  final ProfileStatus status;
  final String? validatedBy;
  final DateTime? validatedAt;
  final DigitalPassport? digitalPassport;
  final DateTime createdAt;

  ExternalProfile({
    required this.id,
    required this.userId,
    required this.country,
    required this.departmentId,
    required this.universityOrCompany,
    required this.localAddress,
    required this.localPhoneNumber,
    required this.arrivalDate,
    required this.userType,
    required this.status,
    this.validatedBy,
    this.validatedAt,
    this.digitalPassport,
    required this.createdAt,
  });
}
