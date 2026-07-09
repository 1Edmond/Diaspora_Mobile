class CommunityUser {
  final String id;
  final String name;
  final String? avatar;
  final String? bio;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final DateTime joinedAt;

  const CommunityUser({
    required this.id,
    required this.name,
    this.avatar,
    this.bio,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    required this.joinedAt,
  });

  CommunityUser copyWith({
    String? id,
    String? name,
    String? avatar,
    String? bio,
    int? postsCount,
    int? followersCount,
    int? followingCount,
    DateTime? joinedAt,
  }) {
    return CommunityUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
