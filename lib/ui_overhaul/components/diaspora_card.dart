import 'package:flutter/material.dart';
import '../theme/diaspora_ui_tokens.dart';

class DiasporaCard extends StatelessWidget {
  const DiasporaCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusLg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .45)),
      ),
      padding: padding,
      child: child,
    );
    if (onTap == null) return card;
    return Semantics(button: true, child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusLg),
      child: card,
    ));
  }
}
