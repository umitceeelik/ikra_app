import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/surah.dart';
import '../../../domain/repositories/quran_repository.dart';

part 'surah_list_event.dart';
part 'surah_list_state.dart';

class SurahListBloc extends Bloc<SurahListEvent, SurahListState> {
  final QuranRepository repo;
  SurahListBloc(this.repo) : super(const SurahListState.loading()) {
    on<SurahListRequested>((event, emit) async {
      emit(const SurahListState.loading());
      try {
        await repo.seedFromAssetIfEmpty();   // ilk açılışta veriyi yükle
        final list = await repo.getSurahList();
        emit(SurahListState.loaded(list));
      } catch (e) {
        emit(SurahListState.error(e.toString()));
      }
    });
  }
}
