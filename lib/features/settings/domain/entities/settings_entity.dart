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

  // Home page personalization — which sections show, and in what layout.
  // Purely local/device preferences (Hive), same storage as the rest of
  // SettingsEntity — no backend involved.
  final bool homeShowQuickAccess;
  final bool homeQuickAccessHorizontal; // true = horizontal scroll row, false = grid
  final bool homeShowProceduresStats;
  final bool homeShowCommunityFeed;
  final bool homeShowCommitteeList;

  bool get darkMode => theme == 'dark';

  const SettingsEntity({
    this.theme = 'light',
    this.language = 'FR',
    this.notificationsEnabled = true,
    this.biometricAuthEnabled = false,
    this.privacyLevel = PrivacyLevel.private,
    this.homeShowQuickAccess = true,
    this.homeQuickAccessHorizontal = true,
    this.homeShowProceduresStats = true,
    this.homeShowCommunityFeed = true,
    this.homeShowCommitteeList = true,
  });

  SettingsEntity copyWith({
    String? theme,
    String? language,
    bool? notificationsEnabled,
    bool? biometricAuthEnabled,
    PrivacyLevel? privacyLevel,
    bool? homeShowQuickAccess,
    bool? homeQuickAccessHorizontal,
    bool? homeShowProceduresStats,
    bool? homeShowCommunityFeed,
    bool? homeShowCommitteeList,
  }) {
    return SettingsEntity(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      homeShowQuickAccess: homeShowQuickAccess ?? this.homeShowQuickAccess,
      homeQuickAccessHorizontal:
          homeQuickAccessHorizontal ?? this.homeQuickAccessHorizontal,
      homeShowProceduresStats:
          homeShowProceduresStats ?? this.homeShowProceduresStats,
      homeShowCommunityFeed: homeShowCommunityFeed ?? this.homeShowCommunityFeed,
      homeShowCommitteeList: homeShowCommitteeList ?? this.homeShowCommitteeList,
    );
  }
}
