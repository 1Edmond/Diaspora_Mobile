import 'package:diaspora_app/core/constants/enums.dart';
import 'digital_passport.dart';

class InternalProfile {
  final String id;
  final String userId;
  final String fullName;
  final DateTime dateOfBirth;
  final String passportNumber;
  final String nationalIdNumber;
  final String? profilePhoto;
  final UserType userType;
  final ProfileStatus status;
  final String? validatedBy;
  final DateTime? validatedAt;
  final DigitalPassport? digitalPassport;
  final DateTime createdAt;

  InternalProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.dateOfBirth,
    required this.passportNumber,
    required this.nationalIdNumber,
    this.profilePhoto,
    required this.userType,
    required this.status,
    this.validatedBy,
    this.validatedAt,
    this.digitalPassport,
    required this.createdAt,
  });
}
