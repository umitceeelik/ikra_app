import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikra/domain/repositories/quran_repository.dart';
import 'package:ikra/presentation/surah_detail/bloc/surah_detail_event.dart';
import 'package:ikra/presentation/surah_detail/bloc/surah_detail_state.dart';

/// BLoC that handles the flow for the Surah detail page.
class SurahDetailBloc extends Bloc<SurahDetailEvent, SurahDetailState> {
  final QuranRepository repo;

  SurahDetailBloc(this.repo) : super(const SurahDetailState.loading()) {
    on<SurahDetailRequested>((event, emit) async {
      emit(const SurahDetailState.loading());
      try {
        final ayah = await repo.getSurahAyah(event.surah);
        emit(SurahDetailState.loaded(ayah));
      } catch (e) {
        emit(SurahDetailState.error(e.toString()));
      }
    });
  }
}
