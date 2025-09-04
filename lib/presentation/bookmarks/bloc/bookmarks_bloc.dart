import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikra/domain/repositories/quran_repository.dart';
import 'package:ikra/presentation/bookmarks/bloc/bookmarks_event.dart';
import 'package:ikra/presentation/bookmarks/bloc/bookmarks_state.dart';

/// BLoC that manages bookmark list and toggle actions.
class BookmarksBloc extends Bloc<BookmarksEvent, BookmarksState> {
  final QuranRepository repo;
  BookmarksBloc(this.repo) : super(const BookmarksState.loading()) {
    on<BookmarksRequested>((event, emit) async {
      emit(const BookmarksState.loading());
      try {
        final list = await repo.getBookmarks();
        emit(BookmarksState.loaded(list));
      } catch (e) {
        emit(BookmarksState.error(e.toString()));
      }
    });

    on<BookmarkToggled>((event, emit) async {
      try {
        await repo.toggleBookmark(event.surah, event.ayah);
        final list = await repo.getBookmarks();
        emit(BookmarksState.loaded(list));
      } catch (e) {
        emit(BookmarksState.error(e.toString()));
      }
    });
  }
}
