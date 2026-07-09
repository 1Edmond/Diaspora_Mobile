import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class SaveNotificationUseCase {
  final INotificationRepository repository;

  SaveNotificationUseCase(this.repository);

  Future<void> call(NotificationEntity notification) {
    return repository.saveNotification(notification);
  }
}
