import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../domain/usecases/fetch_notifications.dart';
import '../../domain/usecases/mark_notification_as_read.dart';
import '../../domain/usecases/save_notification.dart';
import '../../domain/entities/notification.dart';

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
  );
});

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationEntity>>> {
  final FetchNotificationsUseCase _fetchUseCase;
  final MarkNotificationAsReadUseCase _markAsReadUseCase;
  final SaveNotificationUseCase _saveUseCase;

  NotificationsNotifier({
    required FetchNotificationsUseCase fetchUseCase,
    required MarkNotificationAsReadUseCase markAsReadUseCase,
    required SaveNotificationUseCase saveUseCase,
  }) : _fetchUseCase = fetchUseCase,
       _markAsReadUseCase = markAsReadUseCase,
       _saveUseCase = saveUseCase,
       super(const AsyncValue.loading());

  Future<void> fetchNotifications(String target) async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _fetchUseCase(target);
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _markAsReadUseCase(notificationId);
      // Refresh the list after marking as read
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
      // Refresh the list after saving
      await fetchNotifications(notification.target);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
