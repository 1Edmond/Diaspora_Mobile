import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  Box? get _box {
    try {
      if (Hive.isBoxOpen('settings')) {
        return Hive.box('settings');
      }
    } catch (_) {}
    return null;
  }

  Future<void> save(String key, dynamic value) async =>
      await _box?.put(key, value);
  T? get<T>(String key) => _box?.get(key) as T?;
  Future<void> remove(String key) async => await _box?.delete(key);
  Future<void> clear() async => await _box?.clear();
}
