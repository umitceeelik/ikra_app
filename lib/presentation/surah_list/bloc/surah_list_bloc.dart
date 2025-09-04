import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikra/domain/repositories/quran_repository.dart';
import 'package:ikra/presentation/surah_list/bloc/surah_list_event.dart';
import 'package:ikra/presentation/surah_list/bloc/surah_list_state.dart';

/// BLoC that handles the flow for the Surah list page.
class SurahListBloc extends Bloc<SurahListEvent, SurahListState> {
  final QuranRepository repo;

  SurahListBloc(this.repo) : super(const SurahListState.loading()) {
    // Load data on SurahListRequested
    on<SurahListRequested>((event, emit) async {
      emit(const SurahListState.loading());
      try {
        // Seed local DB from assets on first launch
        await repo.seedFromAssetIfEmpty();

        // Fetch and emit Surah list
        final list = await repo.getSurahList();
        emit(SurahListState.loaded(list));
      } catch (e) {
        emit(SurahListState.error(e.toString()));
      }
    });
  }
}
