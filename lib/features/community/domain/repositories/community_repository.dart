import '../entities/post.dart';
import '../entities/comment.dart';
import '../entities/community_user.dart';

abstract class ICommunityRepository {
  // Posts
  Future<List<Post>> getPosts({int page = 1, int limit = 20});
  Future<Post> getPostById(String postId);
  Future<Post> createPost({
    required String title,
    required String content,
    List<String> images = const [],
    PostType type = PostType.general,
  });
  Future<Post> updatePost(
    String postId, {
    String? title,
    String? content,
    List<String>? images,
  });
  Future<void> deletePost(String postId);

  // Post interactions
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<void> sharePost(String postId);

  // Comments
  Future<List<Comment>> getComments(
    String postId, {
    int page = 1,
    int limit = 20,
  });
  Future<Comment> createComment(
    String postId,
    String content, {
    String? parentCommentId,
  });
  Future<Comment> updateComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
  Future<void> likeComment(String commentId);
  Future<void> unlikeComment(String commentId);

  // User
  Future<CommunityUser> getCurrentUser();
  Future<CommunityUser> getUserById(String userId);
}
