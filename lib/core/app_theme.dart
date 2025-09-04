import 'package:flutter/material.dart';

/// Centralized ThemeData for consistent look & feel across the app.
/// Provides Light, Sepia, and Dark variants.
/// NOTE: Arabic text style is exposed via a helper method so you can inject a fontFamily at runtime.
class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B6A52)),
    );
    return _polish(base);
  }

  static ThemeData sepia() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF7A5C44),
        onPrimary: Colors.white,
        secondary: Color(0xFF94765C),
        surface: Color(0xFFF6EFE6),   // warm paper-like background
        onSurface: Color(0xFF2A2A2A),
      ),
      scaffoldBackgroundColor: const Color(0xFFF6EFE6),
    );
    return _polish(base);
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8B6A52),
        brightness: Brightness.dark,
      ),
    );
    return _polish(base);
  }

  /// Arabic style helper; inject font family if available in pubspec.
  static TextStyle arabic({String? fontFamily}) => TextStyle(
        fontSize: 22,
        height: 2.0,
        fontFamily: fontFamily, // e.g., 'AmiriQuran' or 'KFGQPCUthmanic'
      );

  /// Small visual refinements shared by all themes.
  static ThemeData _polish(ThemeData base) {
    return base.copyWith(
      cardTheme: base.cardTheme.copyWith(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      listTileTheme: base.listTileTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.brown.withOpacity(0.06),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: base.colorScheme.onSurface,
        displayColor: base.colorScheme.onSurface,
      ),
    );
  }
}
