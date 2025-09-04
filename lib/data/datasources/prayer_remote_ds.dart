import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/prayer_day_times.dart';
import '../../domain/entities/prayer_settings.dart';

/// Remote data source to fetch prayer times from an online API (AlAdhan).
/// We use method that matches "Diyanet İşleri Başkanlığı".
class PrayerRemoteDataSource {
  final http.Client _client;
  PrayerRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch prayer times for [date] and [coords] using Diyanet method.
  /// school: 0=Shafi, 1=Hanafi (maps to our Madhab)
  Future<PrayerDayTimes> fetchDiyanetByLatLng({
    required double latitude,
    required double longitude,
    required DateTime date,
    required Madhab madhab,
  }) async {
    // Build yyyy-MM-dd for API
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final dateStr = '$y-$m-$d';

    // AlAdhan timings-by-date with method=Diyanet; school per madhab.
    final school = (madhab == Madhab.hanafi) ? 1 : 0;

    final uri = Uri.parse(
      'https://api.aladhan.com/v1/timings/$dateStr'
      '?latitude=$latitude&longitude=$longitude'
      '&method=13&school=$school', // 13 is often used for Diyanet
    );

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch timings: HTTP ${res.statusCode}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    final timings = data['timings'] as Map<String, dynamic>;

    // Parse local times as device-local DateTime
    DateTime _parse(String hhmm) {
      // Example "05:21 (EET)" or "05:21"; we only take HH:MM
      final parts = hhmm.split(' ').first.split(':');
      final h = int.parse(parts[0]);
      final mn = int.parse(parts[1]);
      return DateTime(date.year, date.month, date.day, h, mn);
    }

    return PrayerDayTimes(
      fajr: _parse(timings['Fajr']),
      sunrise: _parse(timings['Sunrise']),
      dhuhr: _parse(timings['Dhuhr']),
      asr: _parse(timings['Asr']),
      maghrib: _parse(timings['Maghrib']),
      isha: _parse(timings['Isha']),
    );
  }
}
