part of 'surah_list_bloc.dart';

sealed class SurahListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class SurahListRequested extends SurahListEvent {}
