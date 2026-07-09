import '../entities/comment.dart';
import '../repositories/community_repository.dart';

class GetCommentsUseCase {
  final ICommunityRepository repository;

  GetCommentsUseCase(this.repository);

  Future<List<Comment>> execute(String postId, {int page = 1, int limit = 20}) {
    return repository.getComments(postId, page: page, limit: limit);
  }
}
