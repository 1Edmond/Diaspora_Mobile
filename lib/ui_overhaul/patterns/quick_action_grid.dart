import 'package:flutter/material.dart';
import '../components/diaspora_action_tile.dart';

class DiasporaQuickAction {
  const DiasporaQuickAction({required this.label, required this.icon, required this.onTap, this.helper, this.badge});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? helper;
  final String? badge;
}

class DiasporaQuickActionGrid extends StatelessWidget {
  const DiasporaQuickActionGrid({super.key, required this.actions, this.crossAxisCount = 2});
  final List<DiasporaQuickAction> actions;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: actions.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.08),
    itemBuilder: (_, index) {
      final action = actions[index];
      return DiasporaActionTile(label: action.label, icon: action.icon, onTap: action.onTap, helper: action.helper, badge: action.badge);
    },
  );
}
