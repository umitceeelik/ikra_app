import 'package:equatable/equatable.dart';
import '../../../domain/entities/reading_progress.dart';
import '../../../domain/entities/ayah.dart';

/// States produced by the Home BLoC.
class HomeState extends Equatable {
  final bool isLoading;
  final String? error;

  /// Last reading position if available.
  final ReadingProgress? progress;

  /// Verse of the day (Arabic + meta).
  final Ayah? verseOfTheDay;

  const HomeState._({
    this.isLoading = false,
    this.error,
    this.progress,
    this.verseOfTheDay,
  });

  const HomeState.loading() : this._(isLoading: true);

  const HomeState.loaded({
    ReadingProgress? progress,
    Ayah? verseOfTheDay,
  }) : this._(progress: progress, verseOfTheDay: verseOfTheDay);

  const HomeState.error(String msg) : this._(error: msg);

  @override
  List<Object?> get props => [isLoading, error, progress, verseOfTheDay];
}
