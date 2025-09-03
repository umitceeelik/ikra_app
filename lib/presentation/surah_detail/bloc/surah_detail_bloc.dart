import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/ayah.dart';
import '../../../domain/repositories/quran_repository.dart';

part 'surah_detail_event.dart';
part 'surah_detail_state.dart';

class SurahDetailBloc extends Bloc<SurahDetailEvent, SurahDetailState> {
  final QuranRepository repo;
  SurahDetailBloc(this.repo) : super(const SurahDetailState.loading()) {
    on<SurahDetailRequested>((event, emit) async {
      emit(const SurahDetailState.loading());
      try {
        final list = await repo.getSurahAyat(event.surah);
        emit(SurahDetailState.loaded(list));
      } catch (e) {
        emit(SurahDetailState.error(e.toString()));
      }
    });
  }
}
