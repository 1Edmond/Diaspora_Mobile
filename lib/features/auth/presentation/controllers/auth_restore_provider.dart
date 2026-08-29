import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/storage_service.dart';

/// Result of the startup session restore (`AuthNotifier.restoreSession()`):
/// - null = restore still in progress (shows the splash)
/// - true  = authenticated, should land on /home
/// - false = not authenticated, should go to /auth/login (or /onboarding on
///   the very first launch).
final authRestoredProvider = StateProvider<bool?>((ref) => null);

/// Bumped every time [authRestoredProvider] transitions so the GoRouter's
/// `redirect` re-runs (going through `refreshListenable`). Without this, the
/// redirect reads the value once and never re-evaluates after the async
/// `restoreSession()` completes.
final ValueNotifier<int> authRestoreTick = ValueNotifier<int>(0);

const _seenOnboardingKey = 'hasSeenOnboarding';

/// Whether the user has seen the onboarding flow at least once. Persisted in
/// Hive so the onboarding is only shown on the very first launch.
bool hasSeenOnboarding() {
  return StorageService().get<bool>(_seenOnboardingKey) ?? false;
}

Future<void> markOnboardingSeen() async {
  await StorageService().save(_seenOnboardingKey, true);
}