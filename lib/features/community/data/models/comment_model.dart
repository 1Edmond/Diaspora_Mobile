import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  CommentModel({
    required super.id,
    required super.postId,
    required super.authorId,
    required super.authorName,
    super.authorAvatar,
    required super.content,
    required super.createdAt,
    super.updatedAt,
    super.likesCount,
    super.isLiked,
    super.parentCommentId,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json['id'] as String,
    postId: json['postId'] as String,
    authorId: json['authorId'] as String,
    authorName: json['authorName'] as String,
    authorAvatar: json['authorAvatar'] as String?,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt:
        json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
    likesCount: json['likesCount'] as int? ?? 0,
    isLiked: json['isLiked'] as bool? ?? false,
    parentCommentId: json['parentCommentId'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'postId': postId,
    'authorId': authorId,
    'authorName': authorName,
    'authorAvatar': authorAvatar,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'likesCount': likesCount,
    'isLiked': isLiked,
    'parentCommentId': parentCommentId,
  };
}
