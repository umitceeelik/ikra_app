// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerSettingsHiveAdapter extends TypeAdapter<PrayerSettingsHive> {
  @override
  final int typeId = 6;

  @override
  PrayerSettingsHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerSettingsHive()
      ..latitude = fields[0] as double?
      ..longitude = fields[1] as double?
      ..methodIndex = fields[2] as int
      ..madhabIndex = fields[3] as int;
  }

  @override
  void write(BinaryWriter writer, PrayerSettingsHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.methodIndex)
      ..writeByte(3)
      ..write(obj.madhabIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerSettingsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
