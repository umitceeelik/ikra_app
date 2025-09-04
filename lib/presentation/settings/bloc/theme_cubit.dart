import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikra/domain/entities/app_settings.dart';
import 'package:ikra/domain/repositories/settings_repository.dart';

/// State for the ThemeCubit: current settings.
class ThemeState {
  final AppSettings settings;
  const ThemeState(this.settings);

  ThemeState copyWith({AppSettings? settings}) =>
      ThemeState(settings ?? this.settings);
}

/// Cubit to manage app-level theme & Arabic font selection.
/// Loads settings on start and persists on changes.
class ThemeCubit extends Cubit<ThemeState> {
  final SettingsRepository repo;

  ThemeCubit(this.repo)
      : super(const ThemeState(AppSettings(themeMode: AppThemeMode.light))) {
    _load();
  }

  Future<void> _load() async {
    final s = await repo.getSettings();
    emit(ThemeState(s));
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final updated = state.settings.copyWith(themeMode: mode);
    emit(ThemeState(updated));
    await repo.saveSettings(updated);
  }

  Future<void> setArabicFontFamily(String? family) async {
    final updated = state.settings.copyWith(arabicFontFamily: family);
    emit(ThemeState(updated));
    await repo.saveSettings(updated);
  }
}
