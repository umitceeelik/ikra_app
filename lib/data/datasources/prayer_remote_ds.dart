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

    // AlAdhan timings-by-date with method=Diyanet; school per madhab.
    final school = (madhab == Madhab.hanafi) ? 1 : 0;

    // Prefer Uri.https to avoid manual string concat mistakes.
    final uri = Uri.https(
      'api.aladhan.com',
      '/v1/timings/$y-$m-$d',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'method': '13', // Diyanet
        'school': '$school', // 0=Shafi, 1=Hanafi
      },
    );

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch timings: HTTP ${res.statusCode}');
    }

    final root = jsonDecode(res.body) as Map<String, dynamic>;
    final data = root['data'] as Map<String, dynamic>;
    // Cast timings map to <String, dynamic> explicitly
    final Map<String, dynamic> timings = (data['timings'] as Map).cast<String, dynamic>();

    // Helper: read a String value from the timings map safely.
    String _str(String key) {
      final v = timings[key];
      if (v is String) return v.trim();
      if (v == null) {
        throw FormatException('Missing key "$key" in API response.');
      }
      return v.toString().trim();
    }

    // Parse "HH:mm (ZONE)" or "HH:mm" into a local DateTime on [date]
    DateTime _parse(String raw) {
      final hhmm = raw.split(' ').first; // drop "(+03)" or "(EET)" suffixes
      final parts = hhmm.split(':');
      final h = int.parse(parts[0]);
      final mn = int.parse(parts[1]);
      return DateTime(date.year, date.month, date.day, h, mn);
    }

    return PrayerDayTimes(
      fajr: _parse(_str('Fajr')),
      sunrise: _parse(_str('Sunrise')),
      dhuhr: _parse(_str('Dhuhr')),
      asr: _parse(_str('Asr')),
      maghrib: _parse(_str('Maghrib')),
      isha: _parse(_str('Isha')),
    );
  }
}
