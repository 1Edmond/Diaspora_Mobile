import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Back button that pops the current route if possible, otherwise falls back
/// to the app's home screen. Prevents the app from exiting when the current
/// route has no previous page in the navigation stack.
class HomeBackButton extends StatelessWidget {
  const HomeBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      },
    );
  }
}