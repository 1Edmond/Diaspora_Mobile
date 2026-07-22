import 'package:flutter/material.dart';

/// Unified color system for the Diaspora app.
///
/// Palette basée sur les couleurs du drapeau togolais.
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
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FA);
  }

  static Color getCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E2E)
        : const Color(0xFFFFFFFF);
  }

  static Color getTextMain(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE5E7EB)
        : const Color(0xFF1E2A3A);
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF5A6B7C);
  }

  static Color getDivider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFF0033A0).withValues(alpha: 0.08);
  }

  // ── Palette (theme-independent – safe everywhere) ─────────────────────

  // Brand
  static const Color primary = Color(0xFF0033A0); // Bleu Russe – navigation, headers, surfaces
  static const Color primaryLight = Color(0xFF3366CC); // Bleu clair – liens, textes interactifs
  static const Color secondary = Color(0xFF006B3F); // Vert Togolais – statuts OK, succès
  static const Color accent = Color(0xFFCD0021); // Rouge Togolais – CTA principal, notifications
  static const Color accentSoft = Color(0xFFFFCE00); // Jaune Togolais – badges, étoiles, tags
  static const Color onAccentSoft = Color(0xFF1E2A3A); // Texte foncé sur fond jaune (contraste)

  // Semantic
  static const Color success = Color(0xFF006B3F);
  static const Color warning = Color(0xFFFFCE00);
  static const Color error = Color(0xFFCD0021);
  static const Color info = Color(0xFF3366CC);

  // ── Surfaces (theme-dependent – prefer getters above) ─────────────────

  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E2E);

  static const Color textMain = Color(0xFF1E2A3A);
  static const Color textSecondary = Color(0xFF5A6B7C);

  // ── Neumorphic Shadows ────────────────────────────────────────────────

  static const Color lightShadow = Colors.white;
  static final Color darkShadow = const Color(0xFF002080).withValues(alpha: 0.15);
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
    colors: [Color(0xFF0033A0), Color(0xFF0044CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient togoGradient = LinearGradient(
    colors: [Color(0xFF0033A0), Color(0xFF006B3F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8F9FA), Color(0xFFF0F2F5)],
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
          offset: Offset(-offset.dx, -offset.dy),
          blurRadius: blurRadius,
        ),
        BoxShadow(
          color: AppColors.darkModeLightShadow,
          offset: offset,
          blurRadius: blurRadius,
        ),
      ];
    }
    return [
      BoxShadow(
        color: AppColors.darkShadow,
        offset: Offset(-offset.dx, -offset.dy),
        blurRadius: blurRadius,
      ),
      BoxShadow(
        color: AppColors.lightShadow,
        offset: offset,
        blurRadius: blurRadius,
      ),
    ];
  }
}
