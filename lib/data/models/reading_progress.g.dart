// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingProgressHiveAdapter extends TypeAdapter<ReadingProgressHive> {
  @override
  final int typeId = 3;

  @override
  ReadingProgressHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingProgressHive()
      ..surah = fields[0] as int
      ..ayah = fields[1] as int
      ..updatedAt = fields[2] as DateTime;
  }

  @override
  void write(BinaryWriter writer, ReadingProgressHive obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.surah)
      ..writeByte(1)
      ..write(obj.ayah)
      ..writeByte(2)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingProgressHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
