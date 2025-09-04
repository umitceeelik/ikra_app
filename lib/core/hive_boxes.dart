/// Central place for Hive box (table) names.
/// Keeping names in one file prevents typos and eases future refactors.
class HiveBoxes {
  static const surahs = 'surahs'; // Surah list (names, counts)
  static const ayahs  = 'ayahs';  // Verses (Arabic + optional TR/EN)
  static const progress = 'progress'; // Reading progress (single record)
  static const bookmarks = 'bookmarks'; // Saved verses (many)
  static const settings = 'settings';  // App settings (single record)
  static const prayerSettings = 'prayer_settings'; // Prayer calc settings (single)
}
