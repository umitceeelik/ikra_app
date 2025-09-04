import 'package:hive_flutter/hive_flutter.dart';
import '../../core/hive_boxes.dart';
import '../models/app_settings.dart';
import '../../domain/entities/app_settings.dart';

/// Local data source dedicated to App Settings.
/// Stores a single AppSettingsHive record in the 'settings' box.
class SettingsLocalDataSource {
  /// Initialize Hive & open the settings box (idempotent enough for this app).
  Future<void> init() async {
    // It's okay if Hive.initFlutter() was already called elsewhere.
    await Hive.initFlutter();
    Hive.registerAdapter(AppSettingsHiveAdapter());
    await Hive.openBox<AppSettingsHive>(HiveBoxes.settings);
  }

  /// Read the latest settings; return defaults if none exists.
  AppSettings getSettings() {
    final box = Hive.box<AppSettingsHive>(HiveBoxes.settings);
    if (box.isEmpty) {
      return const AppSettings(themeMode: AppThemeMode.light, arabicFontFamily: null);
    }
    // We keep only one record, but take the last just in case.
    final last = box.values.isNotEmpty ? box.values.last : null;
    return last?.toEntity() ?? const AppSettings(themeMode: AppThemeMode.light);
  }

  /// Persist settings, replacing any existing records.
  Future<void> putSettings(AppSettings settings) async {
    final box = Hive.box<AppSettingsHive>(HiveBoxes.settings);
    await box.clear();
    await box.add(AppSettingsHive.fromEntity(settings));
  }
}
