/// Simple in-memory notification service for dev and tests.
class NotificationService {
  final List<Map<String, dynamic>> _store = [];

  /// Push a notification (in-memory)
  void push(Map<String, dynamic> n) {
    _store.insert(0, n);
  }

  /// Fetch notifications for a target (user or provider id)
  List<Map<String, dynamic>> fetch(String target) =>
      _store.where((n) => n['target'] == target).toList();

  /// Mark a notification read by id
  void markRead(String id) {
    final idx = _store.indexWhere((n) => n['id'] == id);
    if (idx != -1) _store[idx]['read'] = true;
  }

  /// Clear all notifications (test helper)
  void clear() => _store.clear();
}
