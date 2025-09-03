import 'package:equatable/equatable.dart';

/// Events that drive the Surah detail BLoC.
sealed class SurahDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load all verses of a specific Surah.
final class SurahDetailRequested extends SurahDetailEvent {
  final int surah;
  SurahDetailRequested(this.surah);
}
