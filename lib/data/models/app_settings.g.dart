// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsHiveAdapter extends TypeAdapter<AppSettingsHive> {
  @override
  final int typeId = 5;

  @override
  AppSettingsHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettingsHive()
      ..themeModeIndex = fields[0] as int
      ..arabicFontFamily = fields[1] as String?;
  }

  @override
  void write(BinaryWriter writer, AppSettingsHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.themeModeIndex)
      ..writeByte(1)
      ..write(obj.arabicFontFamily);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
