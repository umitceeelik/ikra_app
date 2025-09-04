import 'package:hive/hive.dart';
import '../../domain/entities/prayer_settings.dart';

part 'prayer_settings.g.dart';

/// Hive-persisted model for prayer settings (single record).
@HiveType(typeId: 6) // ensure unique typeId across the project
class PrayerSettingsHive extends HiveObject {
  @HiveField(0)
  double? latitude;

  @HiveField(1)
  double? longitude;

  @HiveField(2)
  int methodIndex = 0; // maps to CalcMethod enum index

  @HiveField(3)
  int madhabIndex = 0; // maps to Madhab enum index

  PrayerSettings toEntity() => PrayerSettings(
        latitude: latitude,
        longitude: longitude,
        method: CalcMethod.values[methodIndex],
        madhab: Madhab.values[madhabIndex],
      );

  static PrayerSettingsHive fromEntity(PrayerSettings e) => PrayerSettingsHive()
    ..latitude = e.latitude
    ..longitude = e.longitude
    ..methodIndex = e.method.index
    ..madhabIndex = e.madhab.index;
}
