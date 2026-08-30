import 'package:flutter/material.dart';
import '../components/diaspora_card.dart';

class DiasporaSecureReview extends StatelessWidget {
  const DiasporaSecureReview({super.key, required this.title, required this.rows, required this.confirmLabel, required this.onConfirm, this.warning});
  final String title;
  final List<MapEntry<String, String>> rows;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final String? warning;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 16),
    DiasporaCard(child: Column(children: [for (int i = 0; i < rows.length; i++) ...[
      if (i > 0) const Divider(height: 24),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Text(rows[i].key, style: Theme.of(context).textTheme.bodyMedium)),
        const SizedBox(width: 20),
        Flexible(child: Text(rows[i].value, textAlign: TextAlign.end, style: Theme.of(context).textTheme.titleMedium)),
      ]),
    ]])),
    if (warning != null) ...[
      const SizedBox(height: 12),
      Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Theme.of(context).colorScheme.errorContainer), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.onErrorContainer), const SizedBox(width: 8), Expanded(child: Text(warning!, style: Theme.of(context).textTheme.bodySmall))])),
    ],
    const SizedBox(height: 16),
    FilledButton(onPressed: onConfirm, child: Text(confirmLabel)),
  ]);
}
