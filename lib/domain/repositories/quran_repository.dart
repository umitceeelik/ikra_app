import '../entities/ayah.dart';
import '../entities/reading_progress.dart';
import '../entities/surah.dart';

/// Repository contract that the presentation layer depends on.
/// Data sources (Hive/Assets/API) can change underneath without affecting UI.
abstract class QuranRepository {
  /// On first launch: seed local Hive data using the bundled asset JSON if empty.
  Future<void> seedFromAssetIfEmpty();

  /// Get the list of Surahs (offline).
  Future<List<Surah>> getSurahList();

  /// Get all verses (Ayah) of a given Surah (offline).
  Future<List<Ayah>> getSurahAyah(int surah);

  /// Persist the user's last reading position.
  Future<void> updateReadingProgress(int surah, int ayah);

  /// Retrieve the user's last reading position (if any).
  Future<ReadingProgress?> getReadingProgress();
}
