import '../entities/post.dart';
import '../repositories/community_repository.dart';

class GetPostByIdUseCase {
  final ICommunityRepository repository;

  GetPostByIdUseCase(this.repository);

  Future<Post> execute(String postId) {
    return repository.getPostById(postId);
  }
}
