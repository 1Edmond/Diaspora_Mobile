import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile.dart';
import '../../../../shared/services/storage_service.dart';

const _activeProfileIdKey = 'active_profile_id';

final activeProfileIdProvider = StateNotifierProvider<ActiveProfileIdNotifier, String?>((ref) {
  return ActiveProfileIdNotifier();
});

class ActiveProfileIdNotifier extends StateNotifier<String?> {
  final StorageService _storage;

  ActiveProfileIdNotifier({StorageService? storage})
    : _storage = storage ?? StorageService(),
      super(null) {
    _restore();
  }

  void _restore() {
    final saved = _storage.get<String>(_activeProfileIdKey);
    if (saved != null && saved.isNotEmpty) {
      state = saved;
    }
  }

  void setActiveProfileId(String id) {
    state = id;
    _storage.save(_activeProfileIdKey, id);
  }

  void clear() {
    state = null;
    _storage.remove(_activeProfileIdKey);
  }
}

final profileListProvider =
    StateNotifierProvider<ProfileListNotifier, AsyncValue<List<Profile>>>((ref) {
      return ProfileListNotifier();
    });

class ProfileListNotifier extends StateNotifier<AsyncValue<List<Profile>>> {
  ProfileListNotifier() : super(const AsyncValue.data([]));

  void setProfiles(List<Profile> profiles) {
    state = AsyncValue.data(profiles);
  }

  void setLoading() {
    state = const AsyncValue.loading();
  }

  void setError(Object e, StackTrace st) {
    state = AsyncValue.error(e, st);
  }
}

final activeProfileProvider = Provider<Profile?>((ref) {
  final profiles = ref.watch(profileListProvider).valueOrNull ?? [];
  final activeId = ref.watch(activeProfileIdProvider);
  if (activeId != null) {
    final found = profiles.where((p) => p.id == activeId).firstOrNull;
    if (found != null) return found;
  }
  return profiles.isNotEmpty ? profiles.first : null;
});
