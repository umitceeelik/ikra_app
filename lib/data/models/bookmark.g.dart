// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookmarkHiveAdapter extends TypeAdapter<BookmarkHive> {
  @override
  final int typeId = 4;

  @override
  BookmarkHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookmarkHive()
      ..surah = fields[0] as int
      ..ayah = fields[1] as int
      ..savedAt = fields[2] as DateTime;
  }

  @override
  void write(BinaryWriter writer, BookmarkHive obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.surah)
      ..writeByte(1)
      ..write(obj.ayah)
      ..writeByte(2)
      ..write(obj.savedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
