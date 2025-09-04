import 'package:equatable/equatable.dart';
import '../../../domain/entities/prayer_day_times.dart';
import '../../../domain/entities/prayer_settings.dart';

/// States for prayer times page.
class PrayerState extends Equatable {
  final bool isLoading;
  final String? error;
  final PrayerSettings? settings;
  final PrayerDayTimes? times;

  const PrayerState._({this.isLoading = false, this.error, this.settings, this.times});

  const PrayerState.loading() : this._(isLoading: true);
  const PrayerState.loaded(PrayerSettings s, PrayerDayTimes t) : this._(settings: s, times: t);
  const PrayerState.error(String msg) : this._(error: msg);

  @override
  List<Object?> get props => [isLoading, error, settings, times];
}
