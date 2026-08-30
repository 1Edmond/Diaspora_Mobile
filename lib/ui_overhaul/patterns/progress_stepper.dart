import 'package:flutter/material.dart';
import '../theme/diaspora_ui_tokens.dart';

class DiasporaProgressStepper extends StatelessWidget {
  const DiasporaProgressStepper({super.key, required this.steps, required this.currentIndex});
  final List<String> steps;
  final int currentIndex;

  @override
  Widget build(BuildContext context) => Column(children: [
    Row(children: [
      for (int i = 0; i < steps.length; i++) ...[
        Expanded(child: Column(children: [
          CircleAvatar(radius: 15, backgroundColor: i <= currentIndex ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest, child: i < currentIndex ? const Icon(Icons.check, size: 17, color: Colors.white) : Text('${i + 1}', style: TextStyle(color: i <= currentIndex ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700))),
          const SizedBox(height: 7),
          Text(steps[i], textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
        ])),
        if (i != steps.length - 1) Expanded(child: Container(height: 2, color: i < currentIndex ? Theme.of(context).colorScheme.primary : DiasporaUiTokens.line)),
      ],
    ]),
  ]);
}
