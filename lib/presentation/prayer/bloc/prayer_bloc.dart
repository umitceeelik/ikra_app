import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/prayer_repository.dart';
import '../../../domain/entities/prayer_settings.dart';
import 'prayer_event.dart';
import 'prayer_state.dart';

/// BLoC for Prayer Times page: handles settings + daily computation.
class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final PrayerRepository repo;

  PrayerBloc(this.repo) : super(const PrayerState.loading()) {
    on<PrayerRequested>((event, emit) async {
      emit(const PrayerState.loading());
      try {
        // Load settings
        var s = await repo.getSettings();
        // Ensure we have a location
        s = await repo.ensureLocation(s);
        // Compute today's times
        final t = await repo.computeTimesFor(DateTime.now());
        emit(PrayerState.loaded(s, t));
      } catch (e) {
        emit(PrayerState.error(e.toString()));
      }
    });

    on<PrayerSettingsChanged>((event, emit) async {
      emit(const PrayerState.loading());
      try {
        // Save new settings
        var s = await repo.getSettings();
        s = s.copyWith(method: event.method, madhab: event.madhab);
        await repo.saveSettings(s);

        // Recompute with same date (today)
        final t = await repo.computeTimesFor(DateTime.now());
        emit(PrayerState.loaded(s, t));
      } catch (e) {
        emit(PrayerState.error(e.toString()));
      }
    });
  }
}
