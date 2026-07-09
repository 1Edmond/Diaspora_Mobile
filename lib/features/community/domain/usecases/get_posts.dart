import '../entities/post.dart';
import '../repositories/community_repository.dart';

class GetPostsUseCase {
  final ICommunityRepository repository;

  GetPostsUseCase(this.repository);

  Future<List<Post>> execute({int page = 1, int limit = 20}) {
    return repository.getPosts(page: page, limit: limit);
  }
}
