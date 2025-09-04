import 'package:ikra/data/datasources/settings_local_ds.dart';
import 'package:ikra/domain/entities/app_settings.dart';
import 'package:ikra/domain/repositories/settings_repository.dart';

/// Concrete settings repository backed by Hive local storage.
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource local;
  SettingsRepositoryImpl(this.local);

  @override
  Future<AppSettings> getSettings() async => local.getSettings();

  @override
  Future<void> saveSettings(AppSettings settings) =>
      local.putSettings(settings);
}
