import 'package:equatable/equatable.dart';

/// Domain entity representing a saved verse.
/// Separate from Hive so the domain stays framework-agnostic.
class Bookmark extends Equatable {
  final int surah;     // Surah number (1..114)
  final int ayah;      // Verse number (>=1)
  final DateTime savedAt;

  const Bookmark({required this.surah, required this.ayah, required this.savedAt});

  @override
  List<Object?> get props => [surah, ayah, savedAt];
}
