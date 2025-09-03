import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/quran_repository.dart';
import '../../../domain/entities/ayah.dart';
import '../../../domain/entities/reading_progress.dart';
import 'home_event.dart';
import 'home_state.dart';

/// BLoC for the Home page.
/// Loads: reading progress (if any), and a deterministic "verse of the day".
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final QuranRepository repo;

  HomeBloc(this.repo) : super(const HomeState.loading()) {
    on<HomeRequested>((event, emit) async {
      emit(const HomeState.loading());
      try {
        // Ensure local data is seeded (no-op if already seeded)
        await repo.seedFromAssetIfEmpty();

        // 1) Reading progress
        final ReadingProgress? progress = await repo.getReadingProgress();

        // 2) Verse-of-the-day: choose deterministically from local data
        // Strategy:
        // - Use a fixed epoch; compute days offset to get indices.
        // - Pick a surah by modulo surahCount.
        // - Load its ayat and pick an ayah by modulo ayahCount.
        final surahs = await repo.getSurahList();
        Ayah? votd;
        if (surahs.isNotEmpty) {
          final epoch = DateTime(2020, 1, 1);
          final days = DateTime.now().difference(epoch).inDays.abs();
          final surahIdx = days % surahs.length;
          final surah = surahs[surahIdx];

          final ayat = await repo.getSurahAyah(surah.number);
          if (ayat.isNotEmpty) {
            final ayahIdx = days % ayat.length;
            votd = ayat[ayahIdx];
          }
        }

        emit(HomeState.loaded(progress: progress, verseOfTheDay: votd));
      } catch (e) {
        emit(HomeState.error(e.toString()));
      }
    });
  }
}
