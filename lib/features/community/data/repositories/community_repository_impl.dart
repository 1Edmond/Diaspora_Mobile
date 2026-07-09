import '../../domain/repositories/community_repository.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/community_user.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/community_user_model.dart';
import '../../../../core/network/dio_client.dart';

class CommunityRepositoryImpl implements ICommunityRepository {
  final DioClient _client;

  CommunityRepositoryImpl({DioClient? client})
    : _client = client ?? DioClient();

  @override
  Future<List<Post>> getPosts({int page = 1, int limit = 20}) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/community/posts',
      queryParameters: {'page': page, 'limit': limit},
    );

    final posts =
        (res['posts'] as List<dynamic>?)
            ?.map((json) => PostModel.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];

    return posts;
  }

  @override
  Future<Post> getPostById(String postId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/community/posts/$postId',
    );
    return PostModel.fromJson(res);
  }

  @override
  Future<Post> createPost({
    required String title,
    required String content,
    List<String> images = const [],
    PostType type = PostType.general,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/community/posts',
      data: {
        'title': title,
        'content': content,
        'images': images,
        'type': type.index,
      },
    );

    return PostModel.fromJson(res);
  }

  @override
  Future<Post> updatePost(
    String postId, {
    String? title,
    String? content,
    List<String>? images,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (images != null) data['images'] = images;

    final res = await _client.put<Map<String, dynamic>>(
      '/community/posts/$postId',
      data: data,
    );

    return PostModel.fromJson(res);
  }

  @override
  Future<void> deletePost(String postId) async {
    await _client.delete('/community/posts/$postId');
  }

  @override
  Future<void> likePost(String postId) async {
    await _client.post('/community/posts/$postId/like');
  }

  @override
  Future<void> unlikePost(String postId) async {
    await _client.delete('/community/posts/$postId/like');
  }

  @override
  Future<void> sharePost(String postId) async {
    await _client.post('/community/posts/$postId/share');
  }

  @override
  Future<List<Comment>> getComments(
    String postId, {
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/community/posts/$postId/comments',
      queryParameters: {'page': page, 'limit': limit},
    );

    final comments =
        (res['comments'] as List<dynamic>?)
            ?.map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];

    return comments;
  }

  @override
  Future<Comment> createComment(
    String postId,
    String content, {
    String? parentCommentId,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/community/posts/$postId/comments',
      data: {
        'content': content,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
      },
    );

    return CommentModel.fromJson(res);
  }

  @override
  Future<Comment> updateComment(String commentId, String content) async {
    final res = await _client.put<Map<String, dynamic>>(
      '/community/comments/$commentId',
      data: {'content': content},
    );

    return CommentModel.fromJson(res);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _client.delete('/community/comments/$commentId');
  }

  @override
  Future<void> likeComment(String commentId) async {
    await _client.post('/community/comments/$commentId/like');
  }

  @override
  Future<void> unlikeComment(String commentId) async {
    await _client.delete('/community/comments/$commentId/like');
  }

  @override
  Future<CommunityUser> getCurrentUser() async {
    final res = await _client.get<Map<String, dynamic>>('/community/user');
    return CommunityUserModel.fromJson(res);
  }

  @override
  Future<CommunityUser> getUserById(String userId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/community/users/$userId',
    );
    return CommunityUserModel.fromJson(res);
  }
}
