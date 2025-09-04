import 'package:hive/hive.dart';
import '../../domain/entities/app_settings.dart';

part 'app_settings.g.dart';

/// Hive-persisted model for app settings (single record).
@HiveType(typeId: 5) // make sure typeId is unique in the project
class AppSettingsHive extends HiveObject {
  @HiveField(0)
  late int themeModeIndex; // 0: light, 1: sepia, 2: dark

  @HiveField(1)
  String? arabicFontFamily;

  AppSettings toEntity() => AppSettings(
        themeMode: AppThemeMode.values[themeModeIndex],
        arabicFontFamily: arabicFontFamily,
      );

  static AppSettingsHive fromEntity(AppSettings e) => AppSettingsHive()
    ..themeModeIndex = e.themeMode.index
    ..arabicFontFamily = e.arabicFontFamily;
}
