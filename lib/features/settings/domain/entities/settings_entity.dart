enum PrivacyLevel {
  public('PUBLIC'),
  friendsOnly('FRIENDS_ONLY'),
  private('PRIVATE');

  final String value;
  const PrivacyLevel(this.value);

  factory PrivacyLevel.fromString(String value) {
    return PrivacyLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PrivacyLevel.private,
    );
  }
}

class SettingsEntity {
  final String theme; // 'light' or 'dark'
  final String language; // 'EN', 'FR', 'RU'
  final bool notificationsEnabled;
  final bool biometricAuthEnabled;
  final PrivacyLevel privacyLevel;

  bool get darkMode => theme == 'dark';

  const SettingsEntity({
    this.theme = 'light',
    this.language = 'FR',
    this.notificationsEnabled = true,
    this.biometricAuthEnabled = false,
    this.privacyLevel = PrivacyLevel.private,
  });

  SettingsEntity copyWith({
    String? theme,
    String? language,
    bool? notificationsEnabled,
    bool? biometricAuthEnabled,
    PrivacyLevel? privacyLevel,
  }) {
    return SettingsEntity(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
      privacyLevel: privacyLevel ?? this.privacyLevel,
    );
  }
}
