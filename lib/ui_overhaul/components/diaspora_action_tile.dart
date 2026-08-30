import 'package:flutter/material.dart';
import '../theme/diaspora_ui_tokens.dart';

class DiasporaActionTile extends StatelessWidget {
  const DiasporaActionTile({super.key, required this.label, required this.icon, required this.onTap, this.helper, this.badge});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? helper;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusMd),
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusMd),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .55)),
          ),
          child: Stack(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)),
              const Spacer(),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              if (helper != null) Text(helper!, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
            ]),
            if (badge != null)
              Positioned(top: 0, right: 0, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(20)), child: Text(badge!, style: Theme.of(context).textTheme.labelSmall))),
          ]),
        ),
      ),
    );
  }
}
