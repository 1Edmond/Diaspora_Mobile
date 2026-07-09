import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:diaspora_app/features/notifications/domain/entities/notification.dart';
import 'package:diaspora_app/shared/services/notification_service.dart';

void main() {
  late NotificationRepositoryImpl repository;
  late NotificationService notificationService;

  setUp(() {
    notificationService = NotificationService();
    repository = NotificationRepositoryImpl(
      notificationService: notificationService,
    );
  });

  tearDown(() {
    notificationService.clear();
  });

  group('NotificationRepositoryImpl', () {
    test('fetchNotifications returns list of NotificationEntity', () async {
      // Arrange
      final testNotification = {
        'id': 'test1',
        'target': 'user1',
        'title': 'Test Notification',
        'body': 'Test body',
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      };
      notificationService.push(testNotification);

      // Act
      final result = await repository.fetchNotifications('user1');

      // Assert
      expect(result, isA<List<NotificationEntity>>());
      expect(result.length, 1);
      expect(result.first.id, 'test1');
      expect(result.first.title, 'Test Notification');
      expect(result.first.isRead, false);
    });

    test('markAsRead updates notification read status', () async {
      // Arrange
      final testNotification = {
        'id': 'test2',
        'target': 'user1',
        'title': 'Test Notification',
        'body': 'Test body',
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      };
      notificationService.push(testNotification);

      // Act
      await repository.markAsRead('test2');
      final result = await repository.fetchNotifications('user1');

      // Assert
      expect(result.first.isRead, true);
    });

    test('saveNotification adds notification to service', () async {
      // Arrange
      final notification = NotificationEntity(
        id: 'test3',
        title: 'New Notification',
        body: 'New body',
        timestamp: DateTime.now(),
        target: 'user1',
      );

      // Act
      await repository.saveNotification(notification);
      final result = await repository.fetchNotifications('user1');

      // Assert
      expect(result.length, 1);
      expect(result.first.id, 'test3');
      expect(result.first.title, 'New Notification');
    });
  });
}
