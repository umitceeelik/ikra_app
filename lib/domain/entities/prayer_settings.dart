import 'package:equatable/equatable.dart';

/// Calculation method options (mapped to adhan_dart under the hood).
enum CalcMethod {
  muslimWorldLeague,
  egyptian,
  karachi,
  ummAlQura,
  dubai,
  qatar,
  kuwait,
  northAmerica,
  moonsightingCommittee,
}

/// Juristic method for Asr.
enum Madhab { shafi, hanafi }

enum PrayerSource {
  localCalc,      // legacy (we won’t use it anymore)
  diyanetOnline,  // online source (AlAdhan method=13)
}

/// Domain entity for prayer settings (persisted locally).
class PrayerSettings extends Equatable {
  final double? latitude;
  final double? longitude;
  final CalcMethod method;
  final Madhab madhab;
  final PrayerSource source; // NEW

  const PrayerSettings({
    this.latitude,
    this.longitude,
    required this.method,
    required this.madhab,
    this.source = PrayerSource.diyanetOnline, // <- default online
  });

  bool get hasLocation => latitude != null && longitude != null;

  PrayerSettings copyWith({
    double? latitude,
    double? longitude,
    bool clearLocation = false,
    CalcMethod? method,
    Madhab? madhab,
    PrayerSource? source,
  }) {
    return PrayerSettings(
      latitude: clearLocation ? null : (latitude ?? this.latitude),
      longitude: clearLocation ? null : (longitude ?? this.longitude),
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, method, madhab, source];
}
