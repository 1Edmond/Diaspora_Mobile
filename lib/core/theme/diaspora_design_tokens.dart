import 'package:flutter/material.dart';

/// Product-level tokens for a calm, trustworthy civic/community experience.
/// Keep the existing brand colors, but use them with restraint.
abstract final class DiasporaDesignTokens {
  static const primary = Color(0xFF0033A0);
  static const secondary = Color(0xFF006B3F);
  static const danger = Color(0xFFCD0021);
  static const warning = Color(0xFFFFCE00);

  static const background = Color(0xFFF7F8FA);
  static const surface = Colors.white;
  static const text = Color(0xFF101828);
  static const muted = Color(0xFF667085);
  static const border = Color(0xFFE4E7EC);

  static const radiusSm = 10.0;
  static const radiusMd = 14.0;
  static const radiusLg = 18.0;

  static const space1 = 4.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const space4 = 16.0;
  static const space5 = 20.0;
  static const space6 = 24.0;
  static const space7 = 32.0;

  static const minTouchTarget = 48.0;

  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    secondary: secondary,
    onSecondary: Colors.white,
    error: danger,
    onError: Colors.white,
    surface: surface,
    onSurface: text,
  );

  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF6D8FFF),
    onPrimary: Colors.white,
    secondary: Color(0xFF57B889),
    onSecondary: Colors.black,
    error: Color(0xFFFF6B7F),
    onError: Colors.black,
    surface: Color(0xFF111827),
    onSurface: Color(0xFFF9FAFB),
  );
}
