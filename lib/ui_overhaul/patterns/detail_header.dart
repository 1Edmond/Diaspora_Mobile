import 'package:flutter/material.dart';

class DiasporaDetailHeader extends StatelessWidget {
  const DiasporaDetailHeader({super.key, required this.title, this.subtitle, this.leading, this.trailing, this.status});
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final String? status;

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    if (leading != null) ...[leading!, const SizedBox(width: 12)],
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium)],
      if (status != null) ...[const SizedBox(height: 8), Chip(label: Text(status!))],
    ])),
    if (trailing != null) trailing!,
  ]);
}
