import 'package:hive/hive.dart';
import '../../domain/entities/ayah.dart';

part 'ayah.g.dart';

/// Hive-persisted Ayah model.
/// Note: Hive has no query engine/relations; we filter in code.
@HiveType(typeId: 2)
class AyahHive extends HiveObject {
  @HiveField(0)
  late int surah;          // Surah number

  @HiveField(1)
  late int numberInSurah;  // Verse index inside the surah

  @HiveField(2)
  late String textAr;      // Arabic

  @HiveField(3)
  String? textTr;          // Optional Turkish translation

  @HiveField(4)
  String? textEn;          // Optional English translation

  @HiveField(5)
  late int juz;            // Juz number

  /// Convert to domain entity.
  Ayah toEntity() => Ayah(
        surah: surah,
        numberInSurah: numberInSurah,
        textAr: textAr,
        textTr: textTr,
        textEn: textEn,
        juz: juz,
      );
}
