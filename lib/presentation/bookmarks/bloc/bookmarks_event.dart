import 'package:equatable/equatable.dart';

/// Events that drive the Bookmarks BLoC.
sealed class BookmarksEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load all bookmarks.
final class BookmarksRequested extends BookmarksEvent {}

/// Toggle (add/remove) a bookmark and refresh list.
final class BookmarkToggled extends BookmarksEvent {
  final int surah;
  final int ayah;
  BookmarkToggled(this.surah, this.ayah);
}
