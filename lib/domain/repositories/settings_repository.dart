import '../entities/app_settings.dart';

/// Abstraction for reading/writing app-level settings.
abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
}
