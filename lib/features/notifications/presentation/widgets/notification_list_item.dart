import 'package:flutter/material.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../domain/entities/notification.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _getIcon() {
    // Basic logic since types might not be explicit in the entity yet
    if (notification.title.toLowerCase().contains('alerte'))
      return Icons.warning_amber_rounded;
    if (notification.title.toLowerCase().contains('succès'))
      return Icons.check_circle_outline_rounded;
    return Icons.notifications_none_rounded;
  }

  Color _getColor() {
    if (notification.title.toLowerCase().contains('alerte'))
      return Colors.orange;
    if (notification.title.toLowerCase().contains('succès'))
      return AppColors.accent;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getColor().withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(_getIcon(), color: _getColor(), size: 20),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
            color: AppColors.getTextMain(context),
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          notification.body,
          style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13),
        ),
        trailing:
            notification.isRead
                ? null
                : Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
      ),
    );
  }
}
