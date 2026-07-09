import 'package:get_it/get_it.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import 'package:diaspora_app/shared/services/notification_service.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final NotificationService _notificationService;

  NotificationRepositoryImpl({NotificationService? notificationService})
    : _notificationService =
          notificationService ?? GetIt.instance.get<NotificationService>();

  @override
  Future<List<NotificationEntity>> fetchNotifications(String target) async {
    final notifications = _notificationService.fetch(target);
    return notifications.map((map) => NotificationEntity.fromMap(map)).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    _notificationService.markRead(notificationId);
  }

  @override
  Future<void> saveNotification(NotificationEntity notification) async {
    _notificationService.push(notification.toMap());
  }

  @override
  Future<void> clearNotifications(String target) async {
    // The existing service doesn't have a clear method per target, so we'll clear all
    _notificationService.clear();
  }
}
