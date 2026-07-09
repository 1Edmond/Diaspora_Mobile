import '../../../../core/constants/enums.dart';
import '../../../profile/domain/entities/internal_profile.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.togolesePhoneNumber,
    required super.email,
    required super.chatId,
    required super.communityId,
    required super.walletAccountId,
    required super.documentFolderId,
    super.serviceProviderId,
    required super.internalProfile,
    super.externalProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Adapter to convert legacy/flat JSON to new nested structure temporarily
    // Real implementation should expect nested JSON from backend V2
    return UserModel(
      id: json['id'] as String,
      togolesePhoneNumber: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? 'user@example.com',
      chatId: json['chatId'] as String? ?? 'chat_${json['id']}',
      communityId: json['communityId'] as String? ?? 'comm_${json['id']}',
      walletAccountId:
          json['walletAccountId'] as String? ?? 'wallet_${json['id']}',
      documentFolderId:
          json['documentFolderId'] as String? ?? 'docs_${json['id']}',
      internalProfile: InternalProfile(
        id: 'int_${json['id']}',
        userId: json['id'],
        fullName: json['name'] as String? ?? 'Unknown',
        dateOfBirth: DateTime(2000, 1, 1), // placeholder
        passportNumber: 'P000000', // placeholder
        nationalIdNumber: 'ID000000', // placeholder
        userType: _parseUserType(json['userType']),
        status: _parseStatus(json['status']),
        createdAt: DateTime.now(),
      ),
    );
  }

  static UserType _parseUserType(dynamic val) {
    if (val == 'CONTRACTUEL') return UserType.CONTRACTUEL;
    return UserType.BOURSIER;
  }

  static ProfileStatus _parseStatus(dynamic val) {
    if (val == 'VALIDATED') return ProfileStatus.VALIDATED;
    if (val == 'REJECTED') return ProfileStatus.REJECTED;
    return ProfileStatus.PENDING;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': togolesePhoneNumber,
    'email': email,
    'name': internalProfile.fullName,
    'userType': internalProfile.userType.toString().split('.').last,
    'status': internalProfile.status.toString().split('.').last,
  };
}
