import 'package:equatable/equatable.dart';

/// Supported app theme modes.
enum AppThemeMode { light, sepia, dark }

/// Domain entity representing app-level settings.
class AppSettings extends Equatable {
  final AppThemeMode themeMode;
  final String? arabicFontFamily; // nullable: use system default if null

  const AppSettings({
    required this.themeMode,
    this.arabicFontFamily,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? arabicFontFamily,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      arabicFontFamily: arabicFontFamily ?? this.arabicFontFamily,
    );
  }

  @override
  List<Object?> get props => [themeMode, arabicFontFamily];
}
