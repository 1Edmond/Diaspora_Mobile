import 'package:diaspora_app/core/constants/enums.dart';
import 'package:diaspora_app/features/profile/domain/entities/profile.dart';

final mockProfiles = [
  Profile(
    id: 'prof_int_1',
    userId: 'user_1',
    profileType: 'Internal',
    profileTypeId: 'boursier',
    firstName: 'Kofi',
    lastName: 'Adjovi',
    phoneNumber: '+22890000001',
    status: ProfileStatus.VALIDATED,
    createdAt: DateTime(2025, 1, 15),
    dateOfBirth: DateTime(1998, 5, 12),
  ),
  Profile(
    id: 'prof_ext_1',
    userId: 'user_1',
    profileType: 'External',
    profileTypeId: 'etudiant',
    firstName: 'Kofi',
    lastName: 'Adjovi',
    phoneNumber: '+22890000002',
    status: ProfileStatus.PENDING,
    createdAt: DateTime(2025, 3, 10),
    country: 'France',
    universityOrCompany: 'Université Paris-Saclay',
  ),
];

final mockInternalProfiles = <Profile>[];
final mockExternalProfiles = <Profile>[];
