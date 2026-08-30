import 'package:flutter/material.dart';
import '../theme/diaspora_ui_tokens.dart';

class DiasporaShellItem {
  const DiasporaShellItem({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

class DiasporaShell extends StatelessWidget {
  const DiasporaShell({super.key, required this.currentIndex, required this.onDestinationSelected, required this.body, this.profileLabel, this.profileInitials = 'D', this.onProfileTap, this.destinations = const [
    DiasporaShellItem(label: 'Accueil', icon: Icons.home_outlined),
    DiasporaShellItem(label: 'Communauté', icon: Icons.groups_outlined),
    DiasporaShellItem(label: 'Services', icon: Icons.storefront_outlined),
    DiasporaShellItem(label: 'Messages', icon: Icons.chat_bubble_outline),
    DiasporaShellItem(label: 'Profil', icon: Icons.person_outline),
  ]});
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final String? profileLabel;
  final String profileInitials;
  final VoidCallback? onProfileTap;
  final List<DiasporaShellItem> destinations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        if (profileLabel != null) Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(children: [
            Expanded(child: Text(profileLabel!, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
            IconButton(onPressed: onProfileTap, tooltip: 'Changer de profil', icon: const Icon(Icons.expand_more)),
          ]),
        ),
        Expanded(child: body),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          for (final item in destinations) NavigationDestination(icon: Icon(item.icon), selectedIcon: Icon(_selectedIcon(item.icon)), label: item.label),
        ],
      ),
    );
  }

  IconData _selectedIcon(IconData icon) {
    switch (icon) {
      case Icons.home_outlined:
        return Icons.home;
      case Icons.groups_outlined:
        return Icons.groups;
      case Icons.storefront_outlined:
        return Icons.storefront;
      case Icons.chat_bubble_outline:
        return Icons.chat_bubble;
      case Icons.person_outline:
        return Icons.person;
      default:
        return icon;
    }
  }
}
