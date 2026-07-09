import '../entities/notification.dart';

abstract class INotificationRepository {
  Future<List<NotificationEntity>> fetchNotifications(String target);
  Future<void> markAsRead(String notificationId);
  Future<void> saveNotification(NotificationEntity notification);
  Future<void> clearNotifications(String target);
}
