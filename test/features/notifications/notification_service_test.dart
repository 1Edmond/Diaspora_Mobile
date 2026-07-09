import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_app/shared/services/notification_service.dart';

void main() {
  test('NotificationService push/fetch/markRead', () {
    final svc = NotificationService();
    svc.clear();

    svc.push({
      'id': 'n1',
      'target': 'u1',
      'title': 'Hello',
      'body': 'Test',
      'read': false,
      'createdAt': DateTime.now().toIso8601String(),
    });

    final list = svc.fetch('u1');
    expect(list.length, 1);
    expect(list.first['read'], false);

    svc.markRead('n1');
    final after = svc.fetch('u1');
    expect(after.first['read'], true);
  });
}
