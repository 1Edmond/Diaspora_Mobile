import 'package:flutter/material.dart';
import '../../../../core/theme/design_system.dart';

class StoryAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final Color? avatarColor;
  final bool isOnline;
  final bool isAddButton;
  final double size;
  final VoidCallback? onTap;

  const StoryAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.avatarColor,
    this.isOnline = false,
    this.isAddButton = false,
    this.size = 60,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = avatarColor ?? AppColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: size + 6,
                height: size + 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isAddButton
                      ? null
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withValues(alpha: 0.6),
                            AppColors.accent.withValues(alpha: 0.6),
                          ],
                        ),
                  color: isAddButton
                      ? (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.15))
                      : null,
                ),
                child: Center(
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAddButton
                          ? (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white)
                          : isDark
                              ? const Color(0xFF1E2A3A)
                              : Colors.white,
                      border: isAddButton
                          ? null
                          : Border.all(
                              color: isOnline
                                  ? AppColors.accent
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                    ),
                    child: isAddButton
                        ? Icon(
                            Icons.add_rounded,
                            color: AppColors.getTextSecondary(context),
                            size: 28,
                          )
                        : _buildAvatarContent(color, isDark),
                  ),
                ),
              ),
              if (isOnline && !isAddButton)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF1E2A3A)
                            : Colors.white,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent(Color color, bool isDark) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(color),
        ),
      );
    }
    return _buildFallback(color);
  }

  Widget _buildFallback(Color color) {
    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
