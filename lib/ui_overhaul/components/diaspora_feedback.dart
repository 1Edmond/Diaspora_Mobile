import 'package:flutter/material.dart';
import '../theme/diaspora_ui_tokens.dart';

class DiasporaEmptyState extends StatelessWidget {
  const DiasporaEmptyState({super.key, required this.title, required this.message, this.icon = Icons.inbox_outlined, this.action});
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        if (action != null) ...[const SizedBox(height: 20), action!],
      ]),
    ),
  );
}

class DiasporaErrorState extends StatelessWidget {
  const DiasporaErrorState({super.key, required this.title, required this.message, this.onRetry});
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.cloud_off_outlined, size: 48, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        if (onRetry != null) ...[const SizedBox(height: 20), OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Réessayer'))],
      ]),
    ),
  );
}
