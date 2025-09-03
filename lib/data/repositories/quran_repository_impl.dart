import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_asset_ds.dart';
import '../datasources/quran_local_ds.dart';
import '../models/ayah.dart';
import '../models/surah.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource local;
  final QuranAssetDataSource asset;
  QuranRepositoryImpl({required this.local, required this.asset});

  @override
  Future<void> seedFromAssetIfEmpty() async {
    if (!local.isEmpty()) return;
    final map = await asset.loadJson();
    final surahsRaw = (map['surahs'] as List).cast<Map<String, dynamic>>();

    final surahs = <SurahHive>[];
    final ayahs  = <AyahHive>[];

    for (final s in surahsRaw) {
      final number = s['surahNumber'] as int;
      final nameAr = (s['surahNameArabic'] as String?) ?? '';
      final nameTr = (s['surahNameTurkish'] as String?) ?? '';
      final nameEn = (s['surahNameEnglish'] as String?) ?? '';
      final verses = (s['verses'] as List).cast<Map<String, dynamic>>();

      final surah = SurahHive()
        ..number = number
        ..nameAr = nameAr
        ..nameTr = nameTr
        ..nameEn = nameEn
        ..ayahCount = verses.length;
      surahs.add(surah);

      for (final v in verses) {
        final a = AyahHive()
          ..surah = number
          ..numberInSurah = v['verseNumber'] as int
          ..textAr = (v['text'] as String?) ?? ''
          ..textTr = v['textTurkish'] as String?
          ..textEn = v['textEnglish'] as String?
          ..juz = (v['juzNumber'] as int?) ?? 1;
        ayahs.add(a);
      }
    }
    await local.writeAll(surahs: surahs, ayahs: ayahs);
  }

  @override
  Future<List<Surah>> getSurahList() async => local.getSurahList();

  @override
  Future<List<Ayah>> getSurahAyat(int surah) async => local.getAyatBySurah(surah);
}
