// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surah.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SurahHiveAdapter extends TypeAdapter<SurahHive> {
  @override
  final int typeId = 1;

  @override
  SurahHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurahHive()
      ..number = fields[0] as int
      ..nameAr = fields[1] as String
      ..nameTr = fields[2] as String
      ..nameEn = fields[3] as String
      ..ayahCount = fields[4] as int;
  }

  @override
  void write(BinaryWriter writer, SurahHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.nameAr)
      ..writeByte(2)
      ..write(obj.nameTr)
      ..writeByte(3)
      ..write(obj.nameEn)
      ..writeByte(4)
      ..write(obj.ayahCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurahHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
