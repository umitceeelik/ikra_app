/// Aggregate for a day's prayer times.
class PrayerDayTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const PrayerDayTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  /// Returns the next upcoming prayer name and time based on [now].
  (String name, DateTime time)? nextPrayer(DateTime now) {
    if (now.isBefore(fajr)) return ('Fajr', fajr);
    if (now.isBefore(sunrise)) return ('Sunrise', sunrise);
    if (now.isBefore(dhuhr)) return ('Dhuhr', dhuhr);
    if (now.isBefore(asr)) return ('Asr', asr);
    if (now.isBefore(maghrib)) return ('Maghrib', maghrib);
    if (now.isBefore(isha)) return ('Isha', isha);
    return null;
  }
}
