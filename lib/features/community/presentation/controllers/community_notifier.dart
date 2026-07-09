import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/post.dart';
import '../../domain/entities/comment.dart';
import '../../domain/usecases/get_posts.dart';
import '../../domain/usecases/get_post_by_id.dart';
import '../../domain/usecases/create_post.dart';
import '../../domain/usecases/like_post.dart';
import '../../domain/usecases/get_comments.dart';
import '../../domain/usecases/create_comment.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/realtime/mock_realtime_service.dart';
import 'dart:async';

final communityNotifierProvider =
    StateNotifierProvider<CommunityNotifier, AsyncValue<List<Post>>>((ref) {
      return CommunityNotifier(
        getIt<GetPostsUseCase>(),
        getIt<GetPostByIdUseCase>(),
        getIt<CreatePostUseCase>(),
        getIt<LikePostUseCase>(),
        getIt<UnlikePostUseCase>(),
        getIt<GetCommentsUseCase>(),
        getIt<CreateCommentUseCase>(),
        getIt<MockRealtimeService>(),
      );
    });

final postDetailProvider =
    StateNotifierProvider.family<PostDetailNotifier, AsyncValue<Post?>, String>(
      (ref, postId) {
        return PostDetailNotifier(
          postId,
          getIt<GetPostByIdUseCase>(),
          getIt<LikePostUseCase>(),
          getIt<UnlikePostUseCase>(),
          getIt<GetCommentsUseCase>(),
          getIt<CreateCommentUseCase>(),
        );
      },
    );

class CommunityNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final GetPostsUseCase _getPostsUseCase;
  final CreatePostUseCase _createPostUseCase;
  final LikePostUseCase _likePostUseCase;
  final UnlikePostUseCase _unlikePostUseCase;
  final MockRealtimeService _realtime;
  StreamSubscription<Map<String, dynamic>>? _communitySub;

  CommunityNotifier(
    this._getPostsUseCase,
    GetPostByIdUseCase getPostByIdUseCase,
    this._createPostUseCase,
    this._likePostUseCase,
    this._unlikePostUseCase,
    GetCommentsUseCase getCommentsUseCase,
    CreateCommentUseCase createCommentUseCase,
    this._realtime,
  ) : super(const AsyncValue.loading()) {
    // Subscribe to realtime community events
    _communitySub = _realtime.communityEvents.listen((payload) {
      final event = payload['event'] as String? ?? '';
      if (event == 'post_created') {
        final post = Post(
          id:
              payload['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          authorId: payload['authorId']?.toString() ?? 'anonymous',
          authorName: payload['authorName']?.toString() ?? 'Anonymous',
          authorAvatar: payload['authorAvatar']?.toString(),
          title: payload['title']?.toString() ?? '',
          content: payload['content']?.toString() ?? '',
          images: (payload['images'] as List<dynamic>?)?.cast<String>() ?? [],
          createdAt: DateTime.now(),
        );

        state = state.maybeWhen(
          data: (posts) => AsyncValue.data([post, ...posts]),
          orElse: () => AsyncValue.data([post]),
        );
      } else if (event == 'comment_created') {
        final postId = payload['postId']?.toString();
        if (postId != null) {
          state = state.maybeWhen(
            data:
                (posts) => AsyncValue.data(
                  posts.map((p) {
                    if (p.id == postId) {
                      return p.copyWith(commentsCount: p.commentsCount + 1);
                    }
                    return p;
                  }).toList(),
                ),
            orElse: () => state,
          );
        }
      }
    });

    loadPosts(refresh: true);
  }

  @override
  void dispose() {
    _communitySub?.cancel();
    super.dispose();
  }

  Future<void> loadPosts({bool refresh = false}) async {
    if (!refresh && state.isLoading) return;

    state = const AsyncValue.loading();
    try {
      final posts = await _getPostsUseCase.execute();
      state = AsyncValue.data(posts);
    } catch (e, _) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createPost({
    required String title,
    required String content,
    List<String> images = const [],
    PostType type = PostType.general,
  }) async {
    try {
      final newPost = await _createPostUseCase.execute(
        title: title,
        content: content,
        images: images,
        type: type,
      );

      // Add to the beginning of the list
      state = state.maybeWhen(
        data: (posts) => AsyncValue.data([newPost, ...posts]),
        orElse: () => AsyncValue.data([newPost]),
      );
    } catch (_) {
      // Handle error - could show a snackbar or something
      rethrow;
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _likePostUseCase.execute(postId);

      // Update the post in the list
      state = state.maybeWhen(
        data:
            (posts) => AsyncValue.data(
              posts.map((post) {
                if (post.id == postId) {
                  return post.copyWith(
                    isLiked: true,
                    likesCount: post.likesCount + 1,
                  );
                }
                return post;
              }).toList(),
            ),
        orElse: () => state,
      );
    } catch (_) {
      // Handle error
      rethrow;
    }
  }

  Future<void> unlikePost(String postId) async {
    try {
      await _unlikePostUseCase.execute(postId);

      // Update the post in the list
      state = state.maybeWhen(
        data:
            (posts) => AsyncValue.data(
              posts.map((post) {
                if (post.id == postId) {
                  return post.copyWith(
                    isLiked: false,
                    likesCount: post.likesCount - 1,
                  );
                }
                return post;
              }).toList(),
            ),
        orElse: () => state,
      );
    } catch (_) {
      // Handle error
      rethrow;
    }
  }
}

class PostDetailNotifier extends StateNotifier<AsyncValue<Post?>> {
  final String _postId;
  final GetPostByIdUseCase _getPostByIdUseCase;
  final LikePostUseCase _likePostUseCase;
  final UnlikePostUseCase _unlikePostUseCase;
  final GetCommentsUseCase _getCommentsUseCase;
  final CreateCommentUseCase _createCommentUseCase;

  PostDetailNotifier(
    this._postId,
    this._getPostByIdUseCase,
    this._likePostUseCase,
    this._unlikePostUseCase,
    this._getCommentsUseCase,
    this._createCommentUseCase,
  ) : super(const AsyncValue.loading()) {
    loadPost();
  }

  Future<void> loadPost() async {
    state = const AsyncValue.loading();
    try {
      final post = await _getPostByIdUseCase.execute(_postId);
      state = AsyncValue.data(post);
    } catch (e, _) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> likePost() async {
    try {
      await _likePostUseCase.execute(_postId);

      // Update the post
      state = state.maybeWhen(
        data:
            (post) =>
                post != null
                    ? AsyncValue.data(
                      post.copyWith(
                        isLiked: true,
                        likesCount: post.likesCount + 1,
                      ),
                    )
                    : state,
        orElse: () => state,
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<void> unlikePost() async {
    try {
      await _unlikePostUseCase.execute(_postId);

      // Update the post
      state = state.maybeWhen(
        data:
            (post) =>
                post != null
                    ? AsyncValue.data(
                      post.copyWith(
                        isLiked: false,
                        likesCount: post.likesCount - 1,
                      ),
                    )
                    : state,
        orElse: () => state,
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<List<Comment>> getComments() async {
    try {
      return await _getCommentsUseCase.execute(_postId);
    } catch (_) {
      rethrow;
    }
  }

  Future<Comment> createComment(
    String content, {
    String? parentCommentId,
  }) async {
    try {
      final comment = await _createCommentUseCase.execute(
        _postId,
        content,
        parentCommentId: parentCommentId,
      );

      // Update post comment count
      state = state.maybeWhen(
        data:
            (post) =>
                post != null
                    ? AsyncValue.data(
                      post.copyWith(commentsCount: post.commentsCount + 1),
                    )
                    : state,
        orElse: () => state,
      );

      return comment;
    } catch (_) {
      rethrow;
    }
  }
}
