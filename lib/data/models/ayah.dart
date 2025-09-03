import 'package:hive/hive.dart';
import '../../domain/entities/ayah.dart';

part 'ayah.g.dart';

@HiveType(typeId: 2)
class AyahHive extends HiveObject {
  @HiveField(0) late int surah;          // sure no
  @HiveField(1) late int numberInSurah;  // ayet no (sure içi)
  @HiveField(2) late String textAr;      // Arapça metin
  @HiveField(3) String? textTr;          // meal (opsiyonel)
  @HiveField(4) String? textEn;          // meal (opsiyonel)
  @HiveField(5) late int juz;            // cüz no

  Ayah toEntity() => Ayah(
    surah: surah,
    numberInSurah: numberInSurah,
    textAr: textAr,
    textTr: textTr,
    textEn: textEn,
    juz: juz,
  );
}
