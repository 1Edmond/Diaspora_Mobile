import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/comment.dart';
import '../controllers/community_notifier.dart';
import '../widgets/post_card.dart';
import '../widgets/comment_item.dart';
import '../widgets/comment_input.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoadingComments = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final comments =
          await ref
              .read(postDetailProvider(widget.postId).notifier)
              .getComments();
      setState(() => _comments = comments);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des commentaires: $e'),
          ),
        );
      }
    } finally {
      setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _addComment(String content) async {
    try {
      final comment = await ref
          .read(postDetailProvider(widget.postId).notifier)
          .createComment(content);
      setState(() => _comments = [comment, ..._comments]);
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout du commentaire: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => ref.invalidate(postDetailProvider(widget.postId)),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
        data:
            (post) =>
                post == null
                    ? const Center(child: Text('Post non trouvé'))
                    : Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(postDetailProvider(widget.postId));
                              await _loadComments();
                            },
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                PostCard(
                                  post: post,
                                  showFullContent: true,
                                  onTap: () {}, // Already on detail screen
                                  onLike: () async {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    try {
                                      if (post.isLiked) {
                                        await ref
                                            .read(
                                              postDetailProvider(
                                                widget.postId,
                                              ).notifier,
                                            )
                                            .unlikePost();
                                      } else {
                                        await ref
                                            .read(
                                              postDetailProvider(
                                                widget.postId,
                                              ).notifier,
                                            )
                                            .likePost();
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        messenger.showSnackBar(
                                          SnackBar(content: Text('Erreur: $e')),
                                        );
                                      }
                                    }
                                  },
                                  onComment: () {
                                    // Focus on comment input
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());
                                  },
                                  onShare: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Fonction de partage à venir',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Commentaires',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_isLoadingComments)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                else if (_comments.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32),
                                      child: Text(
                                        'Aucun commentaire pour le moment',
                                      ),
                                    ),
                                  )
                                else
                                  ..._comments.map(
                                    (comment) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: CommentItem(comment: comment),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        CommentInput(
                          controller: _commentController,
                          onSend: _addComment,
                        ),
                      ],
                    ),
      ),
    );
  }
}
