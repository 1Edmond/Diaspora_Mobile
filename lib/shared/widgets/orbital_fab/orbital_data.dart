import 'package:flutter/material.dart';

@immutable
class OrbitalItem {
  final IconData icon;
  final String label;
  final Color color;
  final String? description;
  final VoidCallback? onTap;

  const OrbitalItem({
    required this.icon,
    required this.label,
    required this.color,
    this.description,
    this.onTap,
  });

  OrbitalItem copyWith({
    IconData? icon,
    String? label,
    Color? color,
    String? description,
    VoidCallback? onTap,
  }) {
    return OrbitalItem(
      icon: icon ?? this.icon,
      label: label ?? this.label,
      color: color ?? this.color,
      description: description ?? this.description,
      onTap: onTap ?? this.onTap,
    );
  }
}
