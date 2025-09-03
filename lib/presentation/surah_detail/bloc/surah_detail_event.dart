part of 'surah_detail_bloc.dart';

sealed class SurahDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class SurahDetailRequested extends SurahDetailEvent {
  final int surah;
  SurahDetailRequested(this.surah);
}
