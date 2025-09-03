/// Central place for Hive box (table) names.
/// Keeping names in one file prevents typos and eases future refactors.
class HiveBoxes {
  static const surahs = 'surahs'; // Surah list (names, counts)
  static const ayahs  = 'ayahs';  // Verses (Arabic + optional TR/EN)
  static const progress = 'progress'; // Reading progress (single record)
}
