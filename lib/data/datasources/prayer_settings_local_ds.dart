import 'package:hive_flutter/hive_flutter.dart';
import 'package:ikra/core/hive_boxes.dart';
import 'package:ikra/data/models/prayer_settings.dart';
import 'package:ikra/domain/entities/prayer_settings.dart';

/// Local data source for Prayer Settings stored in Hive.
class PrayerSettingsLocalDataSource {
  /// Initialize Hive & open the prayer settings box (idempotent).
  Future<void> init() async {
    await Hive.initFlutter(); // safe to call multiple times
    Hive.registerAdapter(PrayerSettingsHiveAdapter());
    await Hive.openBox<PrayerSettingsHive>(HiveBoxes.prayerSettings);
  }

  /// Read settings; if none exist, return a safe default (MWL/Shafi, no location).
  PrayerSettings get() {
    final box = Hive.box<PrayerSettingsHive>(HiveBoxes.prayerSettings);
    if (box.isEmpty) {
      return const PrayerSettings(
        method: CalcMethod.muslimWorldLeague,
        madhab: Madhab.shafi,
      );
    }
    return box.values.last.toEntity();
  }

  /// Persist settings, replacing previous records.
  Future<void> put(PrayerSettings settings) async {
    final box = Hive.box<PrayerSettingsHive>(HiveBoxes.prayerSettings);
    await box.clear();
    await box.add(PrayerSettingsHive.fromEntity(settings));
  }
}
