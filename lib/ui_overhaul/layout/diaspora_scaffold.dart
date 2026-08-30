import 'package:flutter/material.dart';
import '../theme/diaspora_ui_tokens.dart';

class DiasporaScaffold extends StatelessWidget {
  const DiasporaScaffold({super.key, required this.body, this.title, this.subtitle, this.actions, this.floatingActionButton, this.bottomNavigationBar, this.scrollable = true, this.backgroundColor});
  final Widget body;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool scrollable;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(DiasporaUiTokens.s4, 12, DiasporaUiTokens.s4, DiasporaUiTokens.s7),
      child: body,
    );
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: title == null ? null : AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title!),
          if (subtitle != null) Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
        ]),
        actions: actions,
      ),
      body: SafeArea(child: scrollable ? SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: content) : content),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
