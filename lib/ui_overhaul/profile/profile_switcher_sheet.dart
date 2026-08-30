import 'package:flutter/material.dart';
import '../components/diaspora_card.dart';
import '../theme/diaspora_ui_tokens.dart';
import 'profile_context.dart';

Future<UiProfile?> showDiasporaProfileSwitcher(BuildContext context, {required List<UiProfile> profiles, required String? activeId, VoidCallback? onCreateProfile}) {
  return showModalBottomSheet<UiProfile>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Changer de profil', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text('Le compte reste le même. Seul le contexte actif change.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 420),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: profiles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final profile = profiles[index];
              final active = profile.id == activeId;
              return DiasporaCard(
                onTap: () => Navigator.of(sheetContext).pop(profile),
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  CircleAvatar(radius: 24, backgroundImage: profile.avatarUrl == null ? null : NetworkImage(profile.avatarUrl!), child: profile.avatarUrl == null ? Text(profile.initials ?? (profile.name.isNotEmpty ? profile.name.substring(0, 1).toUpperCase() : '?')) : null),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(profile.name, style: Theme.of(context).textTheme.titleMedium), if (profile.subtitle != null) Text(profile.subtitle!, style: Theme.of(context).textTheme.bodySmall)])),
                  if (active) const Icon(Icons.check_circle, color: DiasporaUiTokens.green) else const Icon(Icons.chevron_right),
                ]),
              );
            },
          ),
        ),
        if (onCreateProfile != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: onCreateProfile, icon: const Icon(Icons.add), label: const Text('Créer un profil')),
        ],
      ]),
    )),
  );
}
