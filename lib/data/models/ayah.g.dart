// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ayah.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AyahHiveAdapter extends TypeAdapter<AyahHive> {
  @override
  final int typeId = 2;

  @override
  AyahHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AyahHive()
      ..surah = fields[0] as int
      ..numberInSurah = fields[1] as int
      ..textAr = fields[2] as String
      ..textTr = fields[3] as String?
      ..textEn = fields[4] as String?
      ..juz = fields[5] as int;
  }

  @override
  void write(BinaryWriter writer, AyahHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.surah)
      ..writeByte(1)
      ..write(obj.numberInSurah)
      ..writeByte(2)
      ..write(obj.textAr)
      ..writeByte(3)
      ..write(obj.textTr)
      ..writeByte(4)
      ..write(obj.textEn)
      ..writeByte(5)
      ..write(obj.juz);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
