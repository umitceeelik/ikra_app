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
  turkiye,
}

/// Juristic method for Asr.
enum Madhab { shafi, hanafi }

/// Domain entity for prayer settings (persisted locally).
class PrayerSettings extends Equatable {
  final double? latitude;
  final double? longitude;
  final CalcMethod method;
  final Madhab madhab;

  const PrayerSettings({
    this.latitude,
    this.longitude,
    required this.method,
    required this.madhab,
  });

  bool get hasLocation => latitude != null && longitude != null;

  PrayerSettings copyWith({
    double? latitude,
    double? longitude,
    bool clearLocation = false,
    CalcMethod? method,
    Madhab? madhab,
  }) {
    return PrayerSettings(
      latitude: clearLocation ? null : (latitude ?? this.latitude),
      longitude: clearLocation ? null : (longitude ?? this.longitude),
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, method, madhab];
}
