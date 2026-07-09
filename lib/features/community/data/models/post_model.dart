import '../../domain/entities/post.dart';

class PostModel extends Post {
  PostModel({
    required super.id,
    required super.authorId,
    required super.authorName,
    super.authorAvatar,
    required super.title,
    required super.content,
    super.images,
    required super.createdAt,
    super.updatedAt,
    super.likesCount,
    super.commentsCount,
    super.isLiked,
    super.type,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    id: json['id'] as String,
    authorId: json['authorId'] as String,
    authorName: json['authorName'] as String,
    authorAvatar: json['authorAvatar'] as String?,
    title: json['title'] as String,
    content: json['content'] as String,
    images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt:
        json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
    likesCount: json['likesCount'] as int? ?? 0,
    commentsCount: json['commentsCount'] as int? ?? 0,
    isLiked: json['isLiked'] as bool? ?? false,
    type: PostType.values[json['type'] as int? ?? 0],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorId': authorId,
    'authorName': authorName,
    'authorAvatar': authorAvatar,
    'title': title,
    'content': content,
    'images': images,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'likesCount': likesCount,
    'commentsCount': commentsCount,
    'isLiked': isLiked,
    'type': type.index,
  };
}
