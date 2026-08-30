import 'package:flutter/material.dart';
import 'diaspora_ui_tokens.dart';

abstract final class DiasporaUiTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: DiasporaUiTokens.blue,
      brightness: Brightness.light,
    ).copyWith(
      primary: DiasporaUiTokens.blue,
      onPrimary: Colors.white,
      secondary: DiasporaUiTokens.green,
      onSecondary: Colors.white,
      surface: DiasporaUiTokens.surface,
      onSurface: DiasporaUiTokens.ink,
      error: DiasporaUiTokens.red,
      outline: DiasporaUiTokens.line,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: DiasporaUiTokens.canvas,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.7),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 16, height: 1.45),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4),
        bodySmall: TextStyle(fontSize: 12, height: 1.35),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: DiasporaUiTokens.ink,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: DiasporaUiTokens.ink),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: DiasporaUiTokens.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusLg)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusMd),
          borderSide: const BorderSide(color: DiasporaUiTokens.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusMd),
          borderSide: const BorderSide(color: DiasporaUiTokens.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusMd),
          borderSide: const BorderSide(color: DiasporaUiTokens.blue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          backgroundColor: DiasporaUiTokens.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusMd)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: DiasporaUiTokens.blue,
          side: const BorderSide(color: DiasporaUiTokens.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusMd)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: Colors.white,
        indicatorColor: DiasporaUiTokens.blue.withValues(alpha: .10),
        labelTextStyle: WidgetStatePropertyAll(const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: DiasporaUiTokens.blue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF72A9FF),
      secondary: const Color(0xFF62C992),
      surface: DiasporaUiTokens.surfaceDark,
      onSurface: DiasporaUiTokens.inkDark,
      outline: DiasporaUiTokens.lineDark,
      error: const Color(0xFFFF7A7A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: DiasporaUiTokens.canvasDark,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: DiasporaUiTokens.inkDark, letterSpacing: -0.7),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: DiasporaUiTokens.inkDark),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: DiasporaUiTokens.inkDark),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DiasporaUiTokens.inkDark),
        bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: DiasporaUiTokens.inkDark),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: DiasporaUiTokens.inkDark),
        bodySmall: TextStyle(fontSize: 12, height: 1.35, color: DiasporaUiTokens.mutedDark),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: DiasporaUiTokens.inkDark,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: DiasporaUiTokens.inkDark),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: DiasporaUiTokens.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusLg)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DiasporaUiTokens.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusMd),
          borderSide: const BorderSide(color: DiasporaUiTokens.lineDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusMd),
          borderSide: const BorderSide(color: DiasporaUiTokens.lineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DiasporaUiTokens.radiusMd),
          borderSide: const BorderSide(color: Color(0xFF72A9FF), width: 1.5),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: DiasporaUiTokens.surfaceDark,
      ),
    );
  }
}
