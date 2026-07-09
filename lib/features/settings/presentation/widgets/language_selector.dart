import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('Langue', style: Theme.of(context).textTheme.titleMedium),
        ),
        RadioListTile<String>(
          title: const Text('Français'),
          value: 'FR',
          groupValue: selectedLanguage,
          onChanged: (value) {
            if (value != null) onLanguageChanged(value);
          },
        ),
        RadioListTile<String>(
          title: const Text('English'),
          value: 'EN',
          groupValue: selectedLanguage,
          onChanged: (value) {
            if (value != null) onLanguageChanged(value);
          },
        ),
        RadioListTile<String>(
          title: const Text('Русский'),
          value: 'RU',
          groupValue: selectedLanguage,
          onChanged: (value) {
            if (value != null) onLanguageChanged(value);
          },
        ),
      ],
    );
  }
}
