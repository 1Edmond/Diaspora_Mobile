import 'package:flutter/material.dart';
import '../theme/diaspora_ui_tokens.dart';

class DiasporaStatusCard extends StatelessWidget {
  const DiasporaStatusCard({super.key, required this.title, required this.value, this.subtitle, this.icon = Icons.info_outline, this.onTap});
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusLg),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusLg),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .45)),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ])),
          if (onTap != null) const Icon(Icons.chevron_right),
        ]),
      ),
    );
  }
}
