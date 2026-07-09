import '../repositories/community_repository.dart';

class LikePostUseCase {
  final ICommunityRepository repository;

  LikePostUseCase(this.repository);

  Future<void> execute(String postId) {
    return repository.likePost(postId);
  }
}

class UnlikePostUseCase {
  final ICommunityRepository repository;

  UnlikePostUseCase(this.repository);

  Future<void> execute(String postId) {
    return repository.unlikePost(postId);
  }
}
