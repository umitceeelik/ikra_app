import 'package:equatable/equatable.dart';

/// Domain entity to represent the user's last reading position.
class ReadingProgress extends Equatable {
  /// Surah number (1..114)
  final int surah;

  /// Verse number inside the surah (>= 1)
  final int ayah;

  const ReadingProgress({required this.surah, required this.ayah});

  @override
  List<Object?> get props => [surah, ayah];
}
