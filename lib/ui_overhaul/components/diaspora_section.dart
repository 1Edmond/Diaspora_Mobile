import 'package:flutter/material.dart';
import '../theme/diaspora_ui_tokens.dart';

class DiasporaSection extends StatelessWidget {
  const DiasporaSection({super.key, required this.title, this.actionLabel, this.onAction, required this.child});
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DiasporaUiTokens.s6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ]),
        const SizedBox(height: DiasporaUiTokens.s3),
        child,
      ]),
    );
  }
}
