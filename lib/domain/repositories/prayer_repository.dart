import '../entities/prayer_settings.dart';
import '../entities/prayer_day_times.dart';

/// Abstraction for prayer time operations and settings.
abstract class PrayerRepository {
  Future<PrayerSettings> getSettings();
  Future<void> saveSettings(PrayerSettings settings);

  /// Ensure we have a location (permission + fetch). Returns updated settings.
  Future<PrayerSettings> ensureLocation(PrayerSettings current);

  /// Compute prayer times for [date] using stored settings.
  Future<PrayerDayTimes> computeTimesFor(DateTime date);
}
