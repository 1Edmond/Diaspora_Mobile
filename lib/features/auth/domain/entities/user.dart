import '../../../profile/domain/entities/internal_profile.dart';
import '../../../profile/domain/entities/external_profile.dart';

class User {
  final String id;
  final String togolesePhoneNumber;
  final String email;

  // Modular IDs
  final String chatId;
  final String communityId;
  final String walletAccountId;
  final String documentFolderId;
  final String? serviceProviderId;

  // Profiles
  final InternalProfile internalProfile;
  final ExternalProfile? externalProfile;

  User({
    required this.id,
    required this.togolesePhoneNumber,
    required this.email,
    required this.chatId,
    required this.communityId,
    required this.walletAccountId,
    required this.documentFolderId,
    this.serviceProviderId,
    required this.internalProfile,
    this.externalProfile,
  });
}
