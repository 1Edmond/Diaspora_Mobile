import 'package:flutter/material.dart';

/// Unified color system for the Diaspora app.
///
/// Usage guidelines:
/// - For text/background → use theme-aware getters:
///     `getTextMain(context)`, `getTextSecondary(context)`, `getBackground(context)`
/// - For accent/palette colors → use static constants:
///     `primary`, `secondary`, `accent`, `success`, `warning`, `info`
class AppColors {
  // ── Theme-aware getters (use these for text & background) ──────────────

  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFE0E5EC);
  }

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

  // ── Palette (theme-independent – safe everywhere) ─────────────────────

  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color accent = Color(0xFF10B981); // Emerald
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ── Surfaces (theme-dependent – prefer getters above) ─────────────────

  /// Light-mode background (use [getBackground] for theme-aware).
  static const Color background = Color(0xFFE0E5EC);
  static const Color backgroundDark = Color(0xFF1A1A1A);

  /// Light-mode text (use [getTextMain]/[getTextSecondary] for theme-aware).
  static const Color textMain = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

  // ── Neumorphic Shadows ────────────────────────────────────────────────

  static const Color lightShadow = Colors.white;
  static final Color darkShadow = const Color(0xFFA3B1C6).withValues(alpha: 0.4);
  static final Color darkModeLightShadow = Colors.white.withValues(alpha: 0.05);
  static final Color darkModeDarkShadow = Colors.black.withValues(alpha: 0.5);

  // ── Glassmorphic ──────────────────────────────────────────────────────

  static final Color glassBackground = Colors.white.withValues(alpha: 0.2);
  static final Color glassBorder = Colors.white.withValues(alpha: 0.5);

  // ── Shimmer ───────────────────────────────────────────────────────────

  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ── Gradients ─────────────────────────────────────────────────────────

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
