import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile.dart';
import 'profile_providers.dart';

final profileSwitcherProvider =
    StateNotifierProvider<ProfileSwitcherNotifier, ProfileSwitcherState>((ref) {
      return ProfileSwitcherNotifier(ref);
    });

class ProfileSwitcherState {
  final bool isSwitching;
  final String? lastSwitchedName;

  const ProfileSwitcherState({
    this.isSwitching = false,
    this.lastSwitchedName,
  });

  ProfileSwitcherState copyWith({
    bool? isSwitching,
    String? lastSwitchedName,
  }) {
    return ProfileSwitcherState(
      isSwitching: isSwitching ?? this.isSwitching,
      lastSwitchedName: lastSwitchedName ?? this.lastSwitchedName,
    );
  }
}

class ProfileSwitcherNotifier extends StateNotifier<ProfileSwitcherState> {
  final Ref _ref;

  ProfileSwitcherNotifier(this._ref) : super(const ProfileSwitcherState());

  List<Profile> get _profiles =>
      _ref.read(profileListProvider).valueOrNull ?? [];

  Profile? get _activeProfile => _ref.read(activeProfileProvider);

  int get activeIndex {
    final active = _activeProfile;
    if (active == null) return 0;
    final idx = _profiles.indexWhere((p) => p.id == active.id);
    return idx >= 0 ? idx : 0;
  }

  void switchToProfile(String profileId) {
    final profiles = _profiles;
    final target = profiles.where((p) => p.id == profileId).firstOrNull;
    if (target == null) return;

    state = state.copyWith(isSwitching: true, lastSwitchedName: target.fullName);

    _ref.read(activeProfileIdProvider.notifier).setActiveProfileId(profileId);

    state = state.copyWith(isSwitching: false);
  }

  void switchToNext() {
    final profiles = _profiles;
    if (profiles.length <= 1) return;

    final nextIndex = (activeIndex + 1) % profiles.length;
    switchToProfile(profiles[nextIndex].id);
  }

  void switchToPrevious() {
    final profiles = _profiles;
    if (profiles.length <= 1) return;

    final previousIndex =
        (activeIndex - 1 + profiles.length) % profiles.length;
    switchToProfile(profiles[previousIndex].id);
  }

  void clearLastSwitchedName() {
    state = state.copyWith(lastSwitchedName: null);
  }
}
