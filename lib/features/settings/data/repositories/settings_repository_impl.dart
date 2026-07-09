import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  final Box settingsBox;

  SettingsRepositoryImpl({required this.settingsBox});

  static const String _settingsKey = 'user_settings';

  @override
  Future<SettingsEntity> getSettings() async {
    final settingsData = settingsBox.get(_settingsKey);
    if (settingsData != null && settingsData is Map) {
      return SettingsModel.fromJson(Map<String, dynamic>.from(settingsData));
    }
    // Return default settings if not found
    return const SettingsEntity();
  }

  @override
  Future<void> updateSettings(SettingsEntity settings) async {
    final model = SettingsModel.fromEntity(settings);
    await settingsBox.put(_settingsKey, model.toJson());
  }

  @override
  Future<void> deleteAccount() async {
    // Clear all settings when account is deleted
    await settingsBox.clear();
  }
}
