import '../../domain/entities/community_user.dart';

class CommunityUserModel extends CommunityUser {
  CommunityUserModel({
    required super.id,
    required super.name,
    super.avatar,
    super.bio,
    super.postsCount,
    super.followersCount,
    super.followingCount,
    required super.joinedAt,
  });

  factory CommunityUserModel.fromJson(Map<String, dynamic> json) =>
      CommunityUserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        avatar: json['avatar'] as String?,
        bio: json['bio'] as String?,
        postsCount: json['postsCount'] as int? ?? 0,
        followersCount: json['followersCount'] as int? ?? 0,
        followingCount: json['followingCount'] as int? ?? 0,
        joinedAt: DateTime.parse(json['joinedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'bio': bio,
    'postsCount': postsCount,
    'followersCount': followersCount,
    'followingCount': followingCount,
    'joinedAt': joinedAt.toIso8601String(),
  };
}
