import '../../../profile/domain/entities/profile.dart';

class User {
  final String id;
  final String togolesePhoneNumber;
  final String email;

  final String chatId;
  final String communityId;
  final String walletAccountId;
  final String documentFolderId;
  final String? serviceProviderId;

  final List<Profile> profiles;

  User({
    required this.id,
    required this.togolesePhoneNumber,
    required this.email,
    required this.chatId,
    required this.communityId,
    required this.walletAccountId,
    required this.documentFolderId,
    this.serviceProviderId,
    this.profiles = const [],
  });

  Profile? get activeProfile => null;

  User copyWith({
    String? id,
    String? togolesePhoneNumber,
    String? email,
    String? chatId,
    String? communityId,
    String? walletAccountId,
    String? documentFolderId,
    String? serviceProviderId,
    List<Profile>? profiles,
  }) {
    return User(
      id: id ?? this.id,
      togolesePhoneNumber: togolesePhoneNumber ?? this.togolesePhoneNumber,
      email: email ?? this.email,
      chatId: chatId ?? this.chatId,
      communityId: communityId ?? this.communityId,
      walletAccountId: walletAccountId ?? this.walletAccountId,
      documentFolderId: documentFolderId ?? this.documentFolderId,
      serviceProviderId: serviceProviderId ?? this.serviceProviderId,
      profiles: profiles ?? this.profiles,
    );
  }
}
