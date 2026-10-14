import 'package:flutter/material.dart';
import '../../core/config/feature_flags.dart';

class DiasporaShellItem {
  const DiasporaShellItem({required this.label, required this.icon, this.route});
  final String label;
  final IconData icon;
  final String? route;
}

class DiasporaShell extends StatelessWidget {
  const DiasporaShell({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
    this.profileLabel,
    this.profileInitials = 'D',
    this.onProfileTap,
    this.destinations,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final String? profileLabel;
  final String profileInitials;
  final VoidCallback? onProfileTap;
  final List<DiasporaShellItem>? destinations;

  List<DiasporaShellItem> get _activeDestinations {
    if (destinations != null) {
      return destinations!;
    }

    final items = <DiasporaShellItem>[
      const DiasporaShellItem(label: 'Accueil', icon: Icons.home_outlined, route: '/home'),
    ];

    if (FeatureFlags.enableCommunity) {
      items.add(const DiasporaShellItem(label: 'Communauté', icon: Icons.groups_outlined, route: '/community'));
    }
    if (FeatureFlags.enableMarketplace || FeatureFlags.enableServices) {
      items.add(const DiasporaShellItem(label: 'Services', icon: Icons.storefront_outlined, route: '/marketplace'));
    }
    if (FeatureFlags.enableChat) {
      items.add(const DiasporaShellItem(label: 'Messages', icon: Icons.chat_bubble_outline, route: '/chat'));
    }
    if (FeatureFlags.enableProfile) {
      items.add(const DiasporaShellItem(label: 'Profil', icon: Icons.person_outline, route: '/profile'));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final activeItems = _activeDestinations;
    final safeIndex = activeItems.isEmpty
        ? 0
        : currentIndex.clamp(0, activeItems.length - 1);

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
      bottomNavigationBar: activeItems.length >= 2
          ? NavigationBar(
              selectedIndex: safeIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final item in activeItems)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(_selectedIcon(item.icon)),
                    label: item.label,
                  ),
              ],
            )
          : null,
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
