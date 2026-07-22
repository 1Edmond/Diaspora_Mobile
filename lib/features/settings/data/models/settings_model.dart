import '../../domain/entities/settings_entity.dart';

class SettingsModel extends SettingsEntity {
  const SettingsModel({
    required super.theme,
    required super.language,
    required super.notificationsEnabled,
    required super.biometricAuthEnabled,
    required super.privacyLevel,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      theme: json['theme'] as String? ?? 'light',
      language: json['language'] as String? ?? 'FR',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      biometricAuthEnabled: json['biometricAuthEnabled'] as bool? ?? false,
      privacyLevel: PrivacyLevel.fromString(
        json['privacyLevel'] as String? ?? 'PRIVATE',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'biometricAuthEnabled': biometricAuthEnabled,
      'darkMode': darkMode,
      'privacyLevel': privacyLevel.value,
    };
  }

  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      theme: entity.theme,
      language: entity.language,
      notificationsEnabled: entity.notificationsEnabled,
      biometricAuthEnabled: entity.biometricAuthEnabled,
      privacyLevel: entity.privacyLevel,
    );
  }
}
