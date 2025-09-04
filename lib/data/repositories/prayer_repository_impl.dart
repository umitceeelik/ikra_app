import 'package:geolocator/geolocator.dart';
import 'package:adhan_dart/adhan_dart.dart' as adhan;

import '../../domain/entities/prayer_settings.dart';
import '../../domain/entities/prayer_day_times.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/prayer_settings_local_ds.dart';

/// Concrete repository for prayer times:
/// - Stores settings in Hive
/// - Reads device location via geolocator
/// - Computes times via adhan_dart (v1.1.x API)
class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerSettingsLocalDataSource local;

  PrayerRepositoryImpl(this.local);

  @override
  Future<PrayerSettings> getSettings() async => local.get();

  @override
  Future<void> saveSettings(PrayerSettings settings) => local.put(settings);

  @override
  Future<PrayerSettings> ensureLocation(PrayerSettings current) async {
    // 1) Request/check location permission.
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
      // Cannot proceed without permission; return unchanged.
      return current;
    }

    // 2) Get best-available position (last known -> current).
    Position? pos = await Geolocator.getLastKnownPosition();
    pos ??= await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    if (pos == null) return current;

    final updated = current.copyWith(latitude: pos.latitude, longitude: pos.longitude);
    await saveSettings(updated);
    return updated;
  }

  @override
  Future<PrayerDayTimes> computeTimesFor(DateTime date) async {
    final s = await getSettings();
    if (!s.hasLocation) {
      // Keep error text in English for dev logs
      throw Exception('Location is required to compute prayer times.');
    }

    // Map domain enums to adhan_dart parameters.
    final coords = adhan.Coordinates(s.latitude!, s.longitude!); // adhan_dart uses (lat, lng)
    final params = _calcParams(s.method);
    // In adhan_dart, Madhab constants are strings ('hanafi'|'shafi')
    params.madhab = (s.madhab == Madhab.hanafi)
        ? adhan.Madhab.hanafi
        : adhan.Madhab.shafi;

    // adhan_dart constructor expects DateTime + named params (NOT DateComponents)
    final localDate = DateTime(date.year, date.month, date.day);
    final pt = adhan.PrayerTimes(
      date: localDate,
      coordinates: coords,
      calculationParameters: params,
      // precision: false // optional
    );

    // Defensive helper to ensure null-safety under extreme latitudes
    DateTime _nn(DateTime? dt, String label) {
      if (dt == null) {
        throw Exception('Failed to compute $label time.');
      }
      return dt;
    }

    return PrayerDayTimes(
      fajr: _nn(pt.fajr, 'Fajr'),
      sunrise: _nn(pt.sunrise, 'Sunrise'),
      dhuhr: _nn(pt.dhuhr, 'Dhuhr'),
      asr: _nn(pt.asr, 'Asr'),
      maghrib: _nn(pt.maghrib, 'Maghrib'),
      isha: _nn(pt.isha, 'Isha'),
    );
  }

  /// Maps our CalcMethod enum to adhan_dart's CalculationMethod static factories.
  /// NOTE: adhan_dart uses camelCase names (e.g., muslimWorldLeague, ummAlQura, northAmerica).
  adhan.CalculationParameters _calcParams(CalcMethod method) {
    switch (method) {
      case CalcMethod.muslimWorldLeague:
        return adhan.CalculationMethod.muslimWorldLeague(); // ✓ camelCase
      case CalcMethod.egyptian:
        return adhan.CalculationMethod.egyptian();
      case CalcMethod.karachi:
        return adhan.CalculationMethod.karachi();
      case CalcMethod.ummAlQura:
        return adhan.CalculationMethod.ummAlQura();
      case CalcMethod.dubai:
        return adhan.CalculationMethod.dubai();
      case CalcMethod.qatar:
        return adhan.CalculationMethod.qatar();
      case CalcMethod.kuwait:
        return adhan.CalculationMethod.kuwait();
      case CalcMethod.northAmerica:
        return adhan.CalculationMethod.northAmerica();
      case CalcMethod.turkiye:
        return adhan.CalculationMethod.turkiye();
    }
  }
}
