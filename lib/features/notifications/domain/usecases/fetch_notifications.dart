import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class FetchNotificationsUseCase {
  final INotificationRepository repository;

  FetchNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>> call(String target) {
    return repository.fetchNotifications(target);
  }
}
