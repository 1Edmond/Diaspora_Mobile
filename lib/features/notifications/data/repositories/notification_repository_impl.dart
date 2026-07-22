import 'package:get_it/get_it.dart';
import 'dart:convert';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../services/notification_rest_service.dart';
import 'package:diaspora_app/shared/services/notification_service.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final NotificationService _notificationService;
  final NotificationRestService _restService;

  NotificationRepositoryImpl({
    NotificationService? notificationService,
    NotificationRestService? restService,
  }) : _notificationService =
            notificationService ?? GetIt.instance.get<NotificationService>(),
       _restService = restService ?? NotificationRestService();

  @override
  Future<List<NotificationEntity>> fetchNotifications(String target) async {
    try {
      final rawList = await _restService.fetchUnread(userId: target);
      final entities =
          rawList.map((raw) {
            final map = _normalizeApiFormat(raw, target);
            _notificationService.push(map);
            return NotificationEntity.fromMap(map);
          }).toList();
      return entities;
    } catch (_) {
      return _notificationService
          .fetch(target)
          .map((map) => NotificationEntity.fromMap(map))
          .toList();
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _restService.markAsRead(notificationId: notificationId);
    } catch (_) {
      // Fallback to in-memory
    }
    _notificationService.markRead(notificationId);
  }

  @override
  Future<void> saveNotification(NotificationEntity notification) {
    _notificationService.push(notification.toMap());
    return Future.value();
  }

  @override
  Future<void> clearNotifications(String target) {
    _notificationService.clear();
    return Future.value();
  }

  Map<String, dynamic> _normalizeApiFormat(
    Map<String, dynamic> raw,
    String target,
  ) {
    Map<String, dynamic> payload = {};
    final rawPayload = raw['payload'];
    if (rawPayload is String && rawPayload.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawPayload);
        if (decoded is Map<String, dynamic>) payload = decoded;
      } catch (_) {
        // payload wasn't valid JSON, ignore
      }
    } else if (rawPayload is Map<String, dynamic>) {
      payload = rawPayload;
    }

    return {
      'id': raw['id'] ?? '',
      'title': payload['Title'] ?? raw['eventType'] ?? '',
      'body': payload['Body'] ?? '',
      'imageUrl': payload['imageUrl'],
      'timestamp': raw['CreatedAt'] ?? DateTime.now().toIso8601String(),
      'read': raw['IsRead'] ?? false,
      'target': target,
      'data': payload,
    };
  }
}
