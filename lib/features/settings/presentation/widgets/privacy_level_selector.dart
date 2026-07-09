import 'package:flutter/material.dart';
import '../../domain/entities/settings_entity.dart';

class PrivacyLevelSelector extends StatelessWidget {
  final PrivacyLevel selectedLevel;
  final Function(PrivacyLevel) onLevelChanged;

  const PrivacyLevelSelector({
    super.key,
    required this.selectedLevel,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Niveau de confidentialité',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        RadioListTile<PrivacyLevel>(
          title: const Text('Public'),
          subtitle: const Text('Visible par tous'),
          value: PrivacyLevel.public,
          groupValue: selectedLevel,
          onChanged: (value) {
            if (value != null) onLevelChanged(value);
          },
        ),
        RadioListTile<PrivacyLevel>(
          title: const Text('Amis seulement'),
          subtitle: const Text('Visible par les amis'),
          value: PrivacyLevel.friendsOnly,
          groupValue: selectedLevel,
          onChanged: (value) {
            if (value != null) onLevelChanged(value);
          },
        ),
        RadioListTile<PrivacyLevel>(
          title: const Text('Privé'),
          subtitle: const Text('Visible par vous uniquement'),
          value: PrivacyLevel.private,
          groupValue: selectedLevel,
          onChanged: (value) {
            if (value != null) onLevelChanged(value);
          },
        ),
      ],
    );
  }
}
