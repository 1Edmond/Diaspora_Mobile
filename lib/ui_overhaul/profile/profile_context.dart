import 'package:flutter/foundation.dart';

/// UI-only profile context. It deliberately knows nothing about API models.
/// Adapt your existing profile entity to this type at the presentation boundary.
class UiProfile {
  const UiProfile({required this.id, required this.name, this.subtitle, this.avatarUrl, this.initials});
  final String id;
  final String name;
  final String? subtitle;
  final String? avatarUrl;
  final String? initials;
}

class ActiveProfileContext extends ChangeNotifier {
  ActiveProfileContext({List<UiProfile> profiles = const []}) : _profiles = profiles, _activeId = profiles.isNotEmpty ? profiles.first.id : null;
  List<UiProfile> _profiles;
  String? _activeId;

  List<UiProfile> get profiles => List.unmodifiable(_profiles);
  UiProfile? get active => _profiles.cast<UiProfile?>().firstWhere((p) => p?.id == _activeId, orElse: () => null);

  void setProfiles(List<UiProfile> profiles, {String? preferredId}) {
    _profiles = profiles;
    _activeId = profiles.isEmpty ? null : (preferredId != null && profiles.any((p) => p.id == preferredId) ? preferredId : (_activeId != null && profiles.any((p) => p.id == _activeId) ? _activeId : profiles.first.id));
    notifyListeners();
  }

  bool select(String id) {
    if (!_profiles.any((p) => p.id == id)) return false;
    if (_activeId == id) return true;
    _activeId = id;
    notifyListeners();
    return true;
  }
}
