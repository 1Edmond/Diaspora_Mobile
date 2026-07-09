import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';

class ServicesShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ServicesShell({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (i) => navigationShell.goBranch(i),
              backgroundColor: AppColors.getBackground(context),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.getTextSecondary(context),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Accueil'),
                BottomNavigationBarItem(icon: Icon(Icons.book_online_rounded), label: 'Réservations'),
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Mes services'),
                BottomNavigationBarItem(icon: Icon(Icons.tune_rounded), label: 'Paramètres'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
