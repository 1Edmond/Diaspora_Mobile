import 'package:flutter/material.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../domain/entities/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool showFullContent;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostCard({
    super.key,
    required this.post,
    this.showFullContent = false,
    required this.onTap,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  String _getPostTypeLabel(PostType type) {
    switch (type) {
      case PostType.general:
        return 'Général';
      case PostType.question:
        return 'Question';
      case PostType.announcement:
        return 'Annonce';
      case PostType.event:
        return 'Événement';
    }
  }

  Color _getPostTypeColor(PostType type) {
    switch (type) {
      case PostType.general:
        return Colors.blue;
      case PostType.question:
        return Colors.green;
      case PostType.announcement:
        return Colors.orange;
      case PostType.event:
        return Colors.purple;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) return 'il y a ${difference.inDays} j';
    if (difference.inHours > 0) return 'il y a ${difference.inHours} h';
    if (difference.inMinutes > 0) return 'il y a ${difference.inMinutes} min';
    return 'à l\'instant';
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    post.authorAvatar != null
                        ? NetworkImage(post.authorAvatar!)
                        : null,
                child:
                    post.authorAvatar == null
                        ? Text(
                          post.authorName.isNotEmpty
                              ? post.authorName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.getTextMain(context),
                      ),
                    ),
                    Text(
                      _formatTimeAgo(post.createdAt),
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPostTypeColor(post.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getPostTypeLabel(post.type),
                  style: TextStyle(
                    color: _getPostTypeColor(post.type),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextMain(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            showFullContent || post.content.length <= 200
                ? post.content
                : '${post.content.substring(0, 200)}...',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.getTextMain(context),
            ),
          ),
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                post.images.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (c, e, s) => Container(
                      height: 200,
                      color: Colors.grey.withValues(alpha: 0.2),
                      child: const Icon(Icons.broken_image),
                    ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInteractionButton(
                context,
                post.isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                '${post.likesCount}',
                post.isLiked ? Colors.red : AppColors.getTextSecondary(context),
                onLike,
              ),
              _buildInteractionButton(
                context,
                Icons.chat_bubble_outline_rounded,
                '${post.commentsCount}',
                AppColors.getTextSecondary(context),
                onComment,
              ),
              _buildInteractionButton(
                context,
                Icons.share_outlined,
                '',
                AppColors.getTextSecondary(context),
                onShare,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
