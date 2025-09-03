import '../entities/ayah.dart';
import '../entities/surah.dart';

abstract class QuranRepository {
  Future<void> seedFromAssetIfEmpty();
  Future<List<Surah>> getSurahList();
  Future<List<Ayah>> getSurahAyat(int surah);
}
