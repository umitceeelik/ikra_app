import 'package:geolocator/geolocator.dart';
import 'package:ikra/core/errors/network_exceptions.dart';
import 'package:ikra/core/net/connectivity_service.dart';
import 'package:ikra/data/datasources/prayer_remote_ds.dart';
import 'package:ikra/data/datasources/prayer_settings_local_ds.dart';
import 'package:ikra/domain/entities/prayer_day_times.dart';
import 'package:ikra/domain/entities/prayer_settings.dart';
import 'package:ikra/domain/repositories/prayer_repository.dart';

/// Online-only repository for prayer times:
/// - Stores settings in Hive
/// - Reads device location via geolocator
/// - Fetches times from the remote API (Diyanet via AlAdhan)
class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerSettingsLocalDataSource local;
  final PrayerRemoteDataSource remote;
  final ConnectivityService connectivity;

  PrayerRepositoryImpl(this.local, this.remote, this.connectivity);

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
    return computeTimesForWith(s, date);
  }

  @override
  Future<PrayerDayTimes> computeTimesForWith(PrayerSettings settings, DateTime date) async {
    final s = settings;
    if (!s.hasLocation) {
      throw Exception('Location is required to compute prayer times.');
    }

    // Online-only: if offline, bail out with a clear exception.
    final online = await connectivity.hasInternet();
    if (!online) {
      throw NoInternetException(); // upper layers will show an "internet required" UI
    }

    // Fetch from remote (Diyanet via AlAdhan). We honor madhab=Shafi/Hanafi.
    return remote.fetchDiyanetByLatLng(
      latitude: s.latitude!,
      longitude: s.longitude!,
      date: date,
      madhab: s.madhab,
    );
  }
}