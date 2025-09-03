import 'package:hive/hive.dart';
import '../../domain/entities/surah.dart';

part 'surah.g.dart';

@HiveType(typeId: 1)
class SurahHive extends HiveObject {
  @HiveField(0) late int number;
  @HiveField(1) late String nameAr;
  @HiveField(2) late String nameTr;
  @HiveField(3) late String nameEn;
  @HiveField(4) late int ayahCount;

  Surah toEntity() => Surah(
    number: number,
    nameAr: nameAr,
    nameTr: nameTr,
    nameEn: nameEn,
    ayahCount: ayahCount,
  );
}
