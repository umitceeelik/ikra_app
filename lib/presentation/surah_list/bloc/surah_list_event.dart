import 'package:equatable/equatable.dart';

/// Events that drive the Surah list BLoC.
sealed class SurahListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Trigger data loading (called on page open).
final class SurahListRequested extends SurahListEvent {}
