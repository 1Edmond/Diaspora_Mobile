import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import '../../domain/usecases/fetch_notifications.dart';
import '../../domain/usecases/mark_notification_as_read.dart';
import '../../domain/usecases/save_notification.dart';
import '../../domain/entities/notification.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';

final fetchNotificationsUseCaseProvider = Provider<FetchNotificationsUseCase>((
  ref,
) {
  return GetIt.instance.get<FetchNotificationsUseCase>();
});

final markNotificationAsReadUseCaseProvider =
    Provider<MarkNotificationAsReadUseCase>((ref) {
      return GetIt.instance.get<MarkNotificationAsReadUseCase>();
    });

final saveNotificationUseCaseProvider = Provider<SaveNotificationUseCase>((
  ref,
) {
  return GetIt.instance.get<SaveNotificationUseCase>();
});

final unreadCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationsStateProvider);
  final list = state.valueOrNull ?? [];
  return list.where((n) => !n.isRead).length;
});

final notificationsStateProvider = StateNotifierProvider<
  NotificationsNotifier,
  AsyncValue<List<NotificationEntity>>
>((ref) {
  final fetchUseCase = ref.watch(fetchNotificationsUseCaseProvider);
  final markAsReadUseCase = ref.watch(markNotificationAsReadUseCaseProvider);
  final saveUseCase = ref.watch(saveNotificationUseCaseProvider);

  return NotificationsNotifier(
    fetchUseCase: fetchUseCase,
    markAsReadUseCase: markAsReadUseCase,
    saveUseCase: saveUseCase,
    ref: ref,
  );
});

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationEntity>>> {
  final FetchNotificationsUseCase _fetchUseCase;
  final MarkNotificationAsReadUseCase _markAsReadUseCase;
  final SaveNotificationUseCase _saveUseCase;
  final Ref _ref;

  NotificationsNotifier({
    required FetchNotificationsUseCase fetchUseCase,
    required MarkNotificationAsReadUseCase markAsReadUseCase,
    required SaveNotificationUseCase saveUseCase,
    required Ref ref,
  }) : _fetchUseCase = fetchUseCase,
       _markAsReadUseCase = markAsReadUseCase,
       _saveUseCase = saveUseCase,
       _ref = ref,
       super(const AsyncValue.loading());

  Future<void> fetchNotifications(String target) async {
    try {
      final notifications = await _fetchUseCase(target);
      _extractInternalProfileData(notifications);
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _markAsReadUseCase(notificationId);
      if (state.value != null) {
        final updatedNotifications =
            state.value!.map((notification) {
              if (notification.id == notificationId) {
                return notification.copyWith(isRead: true);
              }
              return notification;
            }).toList();
        state = AsyncValue.data(updatedNotifications);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveNotification(NotificationEntity notification) async {
    try {
      await _saveUseCase(notification);
      await fetchNotifications(notification.target);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Called by the SSE layer when a new notification arrives in real-time.
  /// Prepends to the list without clobbering existing state.
  void addNotificationFromSse(NotificationEntity notification) {
    final current = state.valueOrNull ?? [];

    // Deduplicate by id
    if (current.any((n) => n.id == notification.id)) {
      return;
    }

    debugPrint('SSE: new notification "${notification.title}"');
    _extractInternalProfileData([notification]);
    state = AsyncValue.data([notification, ...current]);
  }

  void _extractInternalProfileData(List<NotificationEntity> notifications) {
    for (final n in notifications) {
      final payload = n.data;
      if (payload == null) continue;

      final eventType =
          (payload['Type'] ?? payload['type'] ?? '') as String;
      if (eventType != 'InternalProfileCreatedIntegrationEvent') continue;

      debugPrint(
        'Notifications: received InternalProfileCreatedIntegrationEvent',
      );
      _ref.read(authNotifierProvider.notifier).fetchProfiles();
      return;
    }
  }
}
