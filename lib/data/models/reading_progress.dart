import 'package:hive/hive.dart';
import '../../domain/entities/reading_progress.dart';

part 'reading_progress.g.dart';

/// Hive-persisted model for reading progress.
/// Kept separate from domain to avoid leaking Hive into the domain layer.
@HiveType(typeId: 3) // make sure this ID does not clash with other models
class ReadingProgressHive extends HiveObject {
  @HiveField(0)
  late int surah;

  @HiveField(1)
  late int ayah;

  @HiveField(2)
  late DateTime updatedAt;

  ReadingProgress toEntity() =>
      ReadingProgress(surah: surah, ayah: ayah);

  static ReadingProgressHive fromEntity(ReadingProgress e) =>
      ReadingProgressHive()
        ..surah = e.surah
        ..ayah = e.ayah
        ..updatedAt = DateTime.now();
}
