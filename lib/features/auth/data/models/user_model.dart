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
    super.profiles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
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
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': togolesePhoneNumber,
    'email': email,
  };
}
