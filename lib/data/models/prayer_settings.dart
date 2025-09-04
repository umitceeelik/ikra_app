import 'package:hive/hive.dart';
import '../../domain/entities/prayer_settings.dart';

part 'prayer_settings.g.dart';

/// Hive-persisted model for prayer settings (single record).
@HiveType(typeId: 6) // keep unique
class PrayerSettingsHive extends HiveObject {
  @HiveField(0)
  double? latitude;

  @HiveField(1)
  double? longitude;

  @HiveField(2)
  late int methodIndex; // CalcMethod.index

  @HiveField(3)
  late int madhabIndex; // Madhab.index

  @HiveField(4) // NEW field; older boxes will default to null
  int? sourceIndex; // PrayerSource.index

  PrayerSettings toEntity() => PrayerSettings(
        latitude: latitude,
        longitude: longitude,
        method: CalcMethod.values[methodIndex],
        madhab: Madhab.values[madhabIndex],
        source: sourceIndex == null
            ? PrayerSource.localCalc
            : PrayerSource.values[sourceIndex!],
      );

  static PrayerSettingsHive fromEntity(PrayerSettings e) => PrayerSettingsHive()
    ..latitude = e.latitude
    ..longitude = e.longitude
    ..methodIndex = e.method.index
    ..madhabIndex = e.madhab.index
    ..sourceIndex = e.source.index;
}
