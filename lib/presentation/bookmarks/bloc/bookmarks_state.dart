import 'package:equatable/equatable.dart';
import '../../../domain/entities/bookmark.dart';

/// States produced by the Bookmarks BLoC.
class BookmarksState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<Bookmark>? data;

  const BookmarksState._({this.isLoading = false, this.error, this.data});

  const BookmarksState.loading() : this._(isLoading: true);
  const BookmarksState.loaded(List<Bookmark> items) : this._(data: items);
  const BookmarksState.error(String msg) : this._(error: msg);

  @override
  List<Object?> get props => [isLoading, error, data];
}
