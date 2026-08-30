import 'package:flutter/material.dart';
import '../components/diaspora_card.dart';
import '../components/diaspora_section.dart';
import '../components/diaspora_status_card.dart';
import '../layout/diaspora_scaffold.dart';
import 'quick_action_grid.dart';

class DiasporaHomeOverview extends StatelessWidget {
  const DiasporaHomeOverview({super.key, required this.firstName, required this.actions, required this.attention, required this.onNotifications});
  final String firstName;
  final List<DiasporaQuickAction> actions;
  final List<Widget> attention;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return DiasporaScaffold(
      scrollable: true,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bonjour $firstName 👋', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 4),
            Text('Voici ce qui mérite votre attention.', style: Theme.of(context).textTheme.bodyMedium),
          ])),
          IconButton(onPressed: onNotifications, tooltip: 'Notifications', icon: const Icon(Icons.notifications_none_rounded)),
        ]),
        const SizedBox(height: 20),
        if (attention.isNotEmpty)
          DiasporaSection(title: 'À ne pas manquer', child: Column(children: [for (final item in attention) Padding(padding: const EdgeInsets.only(bottom: 10), child: item)])),
        DiasporaSection(title: 'Accès rapide', child: DiasporaQuickActionGrid(actions: actions)),
        DiasporaSection(title: 'Votre espace', child: const Column(children: [
          DiasporaStatusCard(title: 'Profil actif', value: 'Votre profil courant', icon: Icons.person_outline),
          SizedBox(height: 10),
          DiasporaStatusCard(title: 'Activité récente', value: 'Consultez vos dernières actions', icon: Icons.history),
        ])),
        DiasporaCard(child: Row(children: [
          const Icon(Icons.shield_outlined, size: 30),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Votre confidentialité compte', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 3),
            Text('Les informations sensibles doivent rester visibles seulement là où elles sont utiles.', style: Theme.of(context).textTheme.bodySmall),
          ])),
        ])),
      ]),
    );
  }
}
