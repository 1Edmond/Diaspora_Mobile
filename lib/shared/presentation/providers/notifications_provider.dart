import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../services/notification_service.dart';

final notificationsProvider = StateNotifierProvider<
  NotificationsNotifier,
  AsyncValue<List<Map<String, dynamic>>>
>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final NotificationService _service;
  NotificationsNotifier({NotificationService? service})
    : _service = service ?? GetIt.instance.get<NotificationService>(),
      super(const AsyncValue.loading());

  Future<void> fetch(String target) async {
    state = const AsyncValue.loading();
    try {
      final list = _service.fetch(target);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void pushLocal(Map<String, dynamic> n) {
    _service.push(n);
    state = AsyncValue.data(_service.fetch(n['target'] as String));
  }

  void markRead(String id) {
    _service.markRead(id);
    // no-op update
  }
}
