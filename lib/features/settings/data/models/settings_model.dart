import '../../domain/entities/settings_entity.dart';

class SettingsModel extends SettingsEntity {
  const SettingsModel({
    required super.theme,
    required super.language,
    required super.notificationsEnabled,
    required super.biometricAuthEnabled,
    required super.privacyLevel,
    super.homeShowQuickAccess,
    super.homeQuickAccessHorizontal,
    super.homeShowProceduresStats,
    super.homeShowCommunityFeed,
    super.homeShowCommitteeList,
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
      homeShowQuickAccess: json['homeShowQuickAccess'] as bool? ?? true,
      homeQuickAccessHorizontal:
          json['homeQuickAccessHorizontal'] as bool? ?? true,
      homeShowProceduresStats:
          json['homeShowProceduresStats'] as bool? ?? true,
      homeShowCommunityFeed: json['homeShowCommunityFeed'] as bool? ?? true,
      homeShowCommitteeList: json['homeShowCommitteeList'] as bool? ?? true,
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
      'homeShowQuickAccess': homeShowQuickAccess,
      'homeQuickAccessHorizontal': homeQuickAccessHorizontal,
      'homeShowProceduresStats': homeShowProceduresStats,
      'homeShowCommunityFeed': homeShowCommunityFeed,
      'homeShowCommitteeList': homeShowCommitteeList,
    };
  }

  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      theme: entity.theme,
      language: entity.language,
      notificationsEnabled: entity.notificationsEnabled,
      biometricAuthEnabled: entity.biometricAuthEnabled,
      privacyLevel: entity.privacyLevel,
      homeShowQuickAccess: entity.homeShowQuickAccess,
      homeQuickAccessHorizontal: entity.homeQuickAccessHorizontal,
      homeShowProceduresStats: entity.homeShowProceduresStats,
      homeShowCommunityFeed: entity.homeShowCommunityFeed,
      homeShowCommitteeList: entity.homeShowCommitteeList,
    );
  }
}
