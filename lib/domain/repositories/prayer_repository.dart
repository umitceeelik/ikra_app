import 'package:ikra/domain/entities/prayer_day_times.dart';
import 'package:ikra/domain/entities/prayer_settings.dart';

/// Abstraction for prayer time operations and settings.
abstract class PrayerRepository {
  Future<PrayerSettings> getSettings();
  Future<void> saveSettings(PrayerSettings settings);

  /// Ensure we have a location (permission + fetch). Returns updated settings.
  Future<PrayerSettings> ensureLocation(PrayerSettings current);

  /// Compute prayer times for [date] using settings currently stored in Hive.
  Future<PrayerDayTimes> computeTimesFor(DateTime date);

  /// NEW: Compute using the provided in-memory [settings] (no extra Hive read).
  Future<PrayerDayTimes> computeTimesForWith(
      PrayerSettings settings, DateTime date,);
}
