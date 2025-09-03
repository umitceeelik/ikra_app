import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../../domain/entities/reading_progress.dart';
import '../../domain/entities/bookmark.dart';
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

    final surahModels = <SurahHive>[];
    final ayahModels  = <AyahHive>[];

    for (final s in surahsRaw) {
      final number = s['surahNumber'] as int;
      final nameAr = (s['surahNameArabic'] as String?) ?? '';
      final nameTr = (s['surahNameTurkish'] as String?) ?? '';
      final nameEn = (s['surahNameEnglish'] as String?) ?? '';
      final verses = (s['verses'] as List).cast<Map<String, dynamic>>();

      surahModels.add(
        SurahHive()
          ..number = number
          ..nameAr = nameAr
          ..nameTr = nameTr
          ..nameEn = nameEn
          ..ayahCount = verses.length,
      );

      for (final v in verses) {
        ayahModels.add(
          AyahHive()
            ..surah = number
            ..numberInSurah = v['verseNumber'] as int
            ..textAr = (v['text'] as String?) ?? ''
            ..textTr = v['textTurkish'] as String?
            ..textEn = v['textEnglish'] as String?
            ..juz = (v['juzNumber'] as int?) ?? 1,
        );
      }
    }

    await local.writeAll(surahs: surahModels, ayahs: ayahModels);
  }

  @override
  Future<List<Surah>> getSurahList() async => local.getSurahList();

  @override
  Future<List<Ayah>> getSurahAyah(int surah) async => local.getAyatBySurah(surah);

  // Reading progress
  @override
  Future<void> updateReadingProgress(int surah, int ayah) =>
      local.setReadingProgress(ReadingProgress(surah: surah, ayah: ayah));

  @override
  Future<ReadingProgress?> getReadingProgress() async => local.getReadingProgress();

  // Bookmarks
  @override
  Future<List<Bookmark>> getBookmarks() async => local.getBookmarks();

  @override
  Future<void> toggleBookmark(int surah, int ayah) => local.toggleBookmark(surah, ayah);

  @override
  Future<bool> isBookmarked(int surah, int ayah) async => local.isBookmarked(surah, ayah);
}
