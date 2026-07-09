import '../entities/post.dart';
import '../repositories/community_repository.dart';

class CreatePostUseCase {
  final ICommunityRepository repository;

  CreatePostUseCase(this.repository);

  Future<Post> execute({
    required String title,
    required String content,
    List<String> images = const [],
    PostType type = PostType.general,
  }) {
    return repository.createPost(
      title: title,
      content: content,
      images: images,
      type: type,
    );
  }
}
