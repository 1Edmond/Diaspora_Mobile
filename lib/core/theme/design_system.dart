import 'package:flutter/material.dart';

class AppColors {
  // Get theme-aware background color
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFE0E5EC);
  }

  // Get theme-aware text colors
  static Color getTextMain(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE5E7EB)
        : const Color(0xFF2D3748);
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF718096);
  }

  // Static colors (theme-independent)
  static const Color background = Color(0xFFE0E5EC); // Light mode default
  static const Color backgroundDark = Color(0xFF1A1A1A); // Dark mode
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color accent = Color(0xFF10B981); // Emerald

  // Text Colors (static fallback)
  static const Color textMain = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

  // Neumorphic Shadows
  static const Color lightShadow = Colors.white;
  static final Color darkShadow = const Color(
    0xFFA3B1C6,
  ).withValues(alpha: 0.4);

  // Dark mode shadows
  static final Color darkModeLightShadow = Colors.white.withValues(alpha: 0.05);
  static final Color darkModeDarkShadow = Colors.black.withValues(alpha: 0.5);

  // Glassmorphic Colors
  static final Color glassBackground = Colors.white.withValues(alpha: 0.2);
  static final Color glassBorder = Colors.white.withValues(alpha: 0.5);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF818CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFE0E5EC), Color(0xFFE6EBF2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppShadows {
  static List<BoxShadow> neumorphic({
    double blurRadius = 16,
    Offset offset = const Offset(6, 6),
    bool isDark = false,
  }) {
    if (isDark) {
      return [
        BoxShadow(
          color: AppColors.darkModeLightShadow,
          offset: Offset(-offset.dx, -offset.dy),
          blurRadius: blurRadius,
        ),
        BoxShadow(
          color: AppColors.darkModeDarkShadow,
          offset: offset,
          blurRadius: blurRadius,
        ),
      ];
    }
    return [
      BoxShadow(
        color: AppColors.lightShadow,
        offset: Offset(-offset.dx, -offset.dy),
        blurRadius: blurRadius,
      ),
      BoxShadow(
        color: AppColors.darkShadow,
        offset: offset,
        blurRadius: blurRadius,
      ),
    ];
  }

  static List<BoxShadow> neumorphicInvert({
    double blurRadius = 8,
    Offset offset = const Offset(2, 2),
    bool isDark = false,
  }) {
    if (isDark) {
      return [
        BoxShadow(
          color: AppColors.darkModeDarkShadow,
          offset: offset,
          blurRadius: blurRadius,
        ),
        BoxShadow(
          color: AppColors.darkModeLightShadow,
          offset: Offset(-offset.dx, -offset.dy),
          blurRadius: blurRadius,
        ),
      ];
    }
    return [
      BoxShadow(
        color: AppColors.darkShadow,
        offset: offset,
        blurRadius: blurRadius,
      ),
      BoxShadow(
        color: AppColors.lightShadow,
        offset: Offset(-offset.dx, -offset.dy),
        blurRadius: blurRadius,
      ),
    ];
  }
}
