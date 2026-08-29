import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';

class FreelanceShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const FreelanceShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.72),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _item(context, Icons.work_outline_rounded, Icons.work_rounded,
                    'Jobs', 0, isDark),
                _item(context, Icons.inbox_outlined, Icons.inbox_rounded,
                    'Mes candidatures', 1, isDark),
                _item(context, Icons.storefront_outlined, Icons.storefront_rounded,
                    'Mes offres', 2, isDark),
                _item(context, Icons.notifications_outlined,
                    Icons.notifications_rounded, 'Alertes', 3, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, IconData activeIcon,
      String label, int index, bool isDark) {
    final active = navigationShell.currentIndex == index;
    final color = active
        ? AppColors.primary
        : (isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black38);
    return GestureDetector(
      onTap: () => navigationShell.goBranch(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(active ? activeIcon : icon, color: color, size: 24),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}