import '../repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final INotificationRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  Future<void> call(String notificationId) {
    return repository.markAsRead(notificationId);
  }
}
