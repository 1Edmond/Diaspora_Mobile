import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../../core/di/injection.dart';

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<SettingsEntity>>((ref) {
      return SettingsNotifier(getIt<ISettingsRepository>());
    });

class SettingsNotifier extends StateNotifier<AsyncValue<SettingsEntity>> {
  final ISettingsRepository repository;

  SettingsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await repository.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, _) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateTheme(String theme) async {
    final current = state.value;
    if (current != null) {
      final updated = current.copyWith(theme: theme);
      state = AsyncValue.data(updated);
      try {
        await repository.updateSettings(updated);
      } catch (e, _) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> toggleDarkMode() async {
    final current = state.value;
    if (current != null) {
      final updated = current.copyWith(darkMode: !current.darkMode);
      state = AsyncValue.data(updated);
      try {
        await repository.updateSettings(updated);
      } catch (e, _) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> updateLanguage(String language) async {
    final current = state.value;
    if (current != null) {
      final updated = current.copyWith(language: language);
      state = AsyncValue.data(updated);
      try {
        await repository.updateSettings(updated);
      } catch (e, _) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> toggleNotifications() async {
    final current = state.value;
    if (current != null) {
      final updated = current.copyWith(
        notificationsEnabled: !current.notificationsEnabled,
      );
      state = AsyncValue.data(updated);
      try {
        await repository.updateSettings(updated);
      } catch (e, _) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> toggleBiometricAuth() async {
    final current = state.value;
    if (current != null) {
      final updated = current.copyWith(
        biometricAuthEnabled: !current.biometricAuthEnabled,
      );
      state = AsyncValue.data(updated);
      try {
        await repository.updateSettings(updated);
      } catch (e, _) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> updatePrivacyLevel(PrivacyLevel level) async {
    final current = state.value;
    if (current != null) {
      final updated = current.copyWith(privacyLevel: level);
      state = AsyncValue.data(updated);
      try {
        await repository.updateSettings(updated);
      } catch (e, _) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> deleteAccount() async {
    try {
      await repository.deleteAccount();
      state = const AsyncValue.data(SettingsEntity());
    } catch (e, _) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
