import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_asset_ds.dart';
import '../datasources/quran_local_ds.dart';
import '../models/ayah.dart';
import '../models/surah.dart';

/// Concrete repository implementation.
/// For now: Asset JSON -> Hive (seed) + offline reads.
/// Later: you can add a Remote API and keep this interface unchanged.
class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource local;
  final QuranAssetDataSource asset;

  QuranRepositoryImpl({
    required this.local,
    required this.asset,
  });

  @override
  Future<void> seedFromAssetIfEmpty() async {
    // Skip if already seeded
    if (!local.isEmpty()) return;

    // Load JSON from assets
    final map = await asset.loadJson();

    // JSON shape:
    // { "surahs": [ { surahNumber, surahNameArabic, surahNameTurkish, surahNameEnglish,
    //                 verses: [ { verseNumber, text, textTurkish, textEnglish, juzNumber }, ... ]
    //               }, ... ] }
    final surahsRaw = (map['surahs'] as List).cast<Map<String, dynamic>>();

    final surahModels = <SurahHive>[];
    final ayahModels  = <AyahHive>[];

    for (final s in surahsRaw) {
      final number = s['surahNumber'] as int;
      final nameAr = (s['surahNameArabic'] as String?) ?? '';
      final nameTr = (s['surahNameTurkish'] as String?) ?? '';
      final nameEn = (s['surahNameEnglish'] as String?) ?? '';
      final verses = (s['verses'] as List).cast<Map<String, dynamic>>();

      // Build Surah model
      final surah = SurahHive()
        ..number = number
        ..nameAr = nameAr
        ..nameTr = nameTr
        ..nameEn = nameEn
        ..ayahCount = verses.length;
      surahModels.add(surah);

      // Build Ayah models
      for (final v in verses) {
        final a = AyahHive()
          ..surah = number
          ..numberInSurah = v['verseNumber'] as int
          ..textAr = (v['text'] as String?) ?? ''
          ..textTr = v['textTurkish'] as String?
          ..textEn = v['textEnglish'] as String?
          ..juz = (v['juzNumber'] as int?) ?? 1;
        ayahModels.add(a);
      }
    }

    // Persist everything in one go
    await local.writeAll(surahs: surahModels, ayahs: ayahModels);
  }

  @override
  Future<List<Surah>> getSurahList() async => local.getSurahList();

  @override
  Future<List<Ayah>> getSurahAyah(int surah) async => local.getAyatBySurah(surah);
}
