part of 'surah_list_bloc.dart';

class SurahListState extends Equatable {
  final bool isLoading;
  final List<Surah>? data;
  final String? error;

  const SurahListState._({this.isLoading = false, this.data, this.error});
  const SurahListState.loading() : this._(isLoading: true);
  const SurahListState.loaded(List<Surah> list) : this._(data: list);
  const SurahListState.error(String msg) : this._(error: msg);

  @override
  List<Object?> get props => [isLoading, data, error];
}
