import 'package:flutter/material.dart';

class ThemeSelector extends StatelessWidget {
  final String selectedTheme;
  final Function(String) onThemeChanged;

  const ThemeSelector({
    super.key,
    required this.selectedTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('Thème', style: Theme.of(context).textTheme.titleMedium),
        ),
        RadioListTile<String>(
          title: const Text('Clair'),
          value: 'light',
          groupValue: selectedTheme,
          onChanged: (value) {
            if (value != null) onThemeChanged(value);
          },
        ),
        RadioListTile<String>(
          title: const Text('Sombre'),
          value: 'dark',
          groupValue: selectedTheme,
          onChanged: (value) {
            if (value != null) onThemeChanged(value);
          },
        ),
      ],
    );
  }
}
