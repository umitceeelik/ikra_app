import 'package:equatable/equatable.dart';

/// Events that drive the Home BLoC.
sealed class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Trigger initial load for Home: progress + verse-of-the-day.
final class HomeRequested extends HomeEvent {}
