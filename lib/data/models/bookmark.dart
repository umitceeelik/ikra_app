import 'package:hive/hive.dart';
import '../../domain/entities/bookmark.dart';

part 'bookmark.g.dart';

/// Hive-persisted model for a bookmarked verse.
@HiveType(typeId: 4) // ensure this doesn't clash with other models
class BookmarkHive extends HiveObject {
  @HiveField(0)
  late int surah;

  @HiveField(1)
  late int ayah;

  @HiveField(2)
  late DateTime savedAt;

  Bookmark toEntity() => Bookmark(surah: surah, ayah: ayah, savedAt: savedAt);

  static BookmarkHive fromEntity(Bookmark e) =>
      BookmarkHive()
        ..surah = e.surah
        ..ayah = e.ayah
        ..savedAt = e.savedAt;
}
