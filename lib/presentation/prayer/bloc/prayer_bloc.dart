import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/prayer_repository.dart';
import 'prayer_event.dart';
import 'prayer_state.dart';

/// BLoC for Prayer Times page: handles settings + daily computation.
class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final PrayerRepository repo;

  PrayerBloc(this.repo) : super(const PrayerState.loading()) {
    on<PrayerRequested>((event, emit) async {
      emit(const PrayerState.loading());
      try {
        // 1) Load settings from storage
        var s = await repo.getSettings();

        // 2) Ensure location (ask permission + fetch if needed) and persist
        s = await repo.ensureLocation(s);

        // 3) Compute using the *fresh* in-memory settings object
        final t = await repo.computeTimesForWith(s, DateTime.now());

        emit(PrayerState.loaded(s, t));
      } catch (e) {
        emit(PrayerState.error(e.toString()));
      }
    });

    on<PrayerSourceChanged>((event, emit) async {
      emit(const PrayerState.loading());
      try {
        var s = await repo.getSettings();
        s = s.copyWith(source: event.source);
        await repo.saveSettings(s);
        // Ensure location (for online too) and compute with *fresh* settings
        if (!s.hasLocation) {
          s = await repo.ensureLocation(s);
        }
        final t = await repo.computeTimesForWith(s, DateTime.now());
        emit(PrayerState.loaded(s, t));
      } catch (e) {
        emit(PrayerState.error(e.toString()));
      }
    });
  }
}
