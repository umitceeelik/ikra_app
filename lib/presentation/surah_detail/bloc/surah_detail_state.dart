part of 'surah_detail_bloc.dart';

class SurahDetailState extends Equatable {
  final bool isLoading;
  final List<Ayah>? data;
  final String? error;

  const SurahDetailState._({this.isLoading = false, this.data, this.error});
  const SurahDetailState.loading() : this._(isLoading: true);
  const SurahDetailState.loaded(List<Ayah> list) : this._(data: list);
  const SurahDetailState.error(String msg) : this._(error: msg);

  @override
  List<Object?> get props => [isLoading, data, error];
}
