import 'package:equatable/equatable.dart';
import '../../../domain/entities/prayer_settings.dart';

/// Events driving the prayer times flow.
sealed class PrayerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initialize: ensure location, then compute today's times.
final class PrayerRequested extends PrayerEvent {}

/// User changed calculation method or madhab.
final class PrayerSettingsChanged extends PrayerEvent {
  final CalcMethod method;
  final Madhab madhab;
  PrayerSettingsChanged(this.method, this.madhab);
}
