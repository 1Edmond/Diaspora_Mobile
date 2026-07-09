import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';

class ChatShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ChatShell({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: isDark
                ? _darkBlur
                : _lightBlur,
            child: Container(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.75),
              child: BottomNavigationBar(
                currentIndex: navigationShell.currentIndex,
                onTap: (i) => navigationShell.goBranch(i),
                backgroundColor: Colors.transparent,
                selectedItemColor: isDark
                    ? Colors.white
                    : AppColors.primary,
                unselectedItemColor: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.35),
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline),
                    activeIcon: Icon(Icons.chat_bubble),
                    label: 'Chats',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.contacts_outlined),
                    activeIcon: Icon(Icons.contacts),
                    label: 'Contacts',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    activeIcon: Icon(Icons.settings),
                    label: 'Réglages',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

final _lightBlur = ImageFilter.blur(sigmaX: 20, sigmaY: 20);
final _darkBlur = ImageFilter.blur(sigmaX: 30, sigmaY: 30);
