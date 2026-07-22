import 'dart:math';

import 'package:flutter/material.dart';

class OrbitalSideNav extends StatefulWidget {
  const OrbitalSideNav({super.key});

  @override
  State<OrbitalSideNav> createState() => _OrbitalSideNavState();
}

class _OrbitalSideNavState extends State<OrbitalSideNav>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;
  int hoveredIndex = -1;

  late AnimationController controller;

  final items = [
    {"icon": Icons.home, "label": "Accueil"},
    {"icon": Icons.description, "label": "Démarches"},
    {"icon": Icons.groups, "label": "Comités"},
    {"icon": Icons.forum, "label": "Communauté"},
    {"icon": Icons.person, "label": "Profil"},
  ];

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    super.initState();
  }

  void toggle() {
    setState(() => isOpen = !isOpen);
    isOpen ? controller.forward() : controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      right: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ..._buildOrbitItems(),
          _buildMainButton(),
          if (hoveredIndex != -1) _buildPreview(),
        ],
      ),
    );
  }

  List<Widget> _buildOrbitItems() {
    final radius = 100.0;

    return List.generate(items.length, (index) {
      final angle = (index * 360 / items.length) * (3.14 / 180);

      return AnimatedBuilder(
        animation: controller,
        builder: (_, child) {
          final progress = controller.value;

          return Transform.translate(
            offset: Offset(
              radius * progress * cos(angle),
              radius * progress * sin(angle),
            ),
            child: Opacity(
              opacity: progress,
              child: GestureDetector(
                onTap: () {
                  // 👉 Navigation ici
                },
                onTapDown: (_) {
                  setState(() => hoveredIndex = index);
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Icon(items[index]["icon"] as IconData),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildMainButton() {
    return GestureDetector(
      onTap: toggle,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
        ),
        child: AnimatedRotation(
          turns: isOpen ? 0.125 : 0,
          duration: const Duration(milliseconds: 300),
          child: const Icon(Icons.menu, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final item = items[hoveredIndex];

    return Positioned(
      right: 120,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black.withOpacity(0.7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item["label"] as String,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              "Accédez rapidement à cette section",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
