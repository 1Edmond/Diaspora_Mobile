import '../entities/comment.dart';
import '../repositories/community_repository.dart';

class CreateCommentUseCase {
  final ICommunityRepository repository;

  CreateCommentUseCase(this.repository);

  Future<Comment> execute(
    String postId,
    String content, {
    String? parentCommentId,
  }) {
    return repository.createComment(
      postId,
      content,
      parentCommentId: parentCommentId,
    );
  }
}
