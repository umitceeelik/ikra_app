import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikra/data/datasources/quran_asset_ds.dart';
import 'package:ikra/data/datasources/quran_local_ds.dart';
import 'package:ikra/data/repositories/quran_repository_impl.dart';
import 'package:ikra/domain/repositories/quran_repository.dart';
import 'package:ikra/presentation/bookmarks/bloc/bookmarks_bloc.dart';
import 'package:ikra/presentation/bookmarks/bloc/bookmarks_event.dart';
import 'package:ikra/presentation/bookmarks/bloc/bookmarks_state.dart';
import 'package:ikra/presentation/surah_detail/view/surah_detail_page.dart';

/// Simple Bookmarks page: lists saved verses and allows navigation.
class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    // For simplicity we wire the repo locally (can move to DI later).
    final local = QuranLocalDataSource();
    final asset = QuranAssetDataSource();
    final QuranRepository repo =
        QuranRepositoryImpl(local: local, asset: asset);

    return FutureBuilder(
      future: local.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()),);
        }
        return BlocProvider(
          create: (_) => BookmarksBloc(repo)..add(BookmarksRequested()),
          child: Scaffold(
            appBar: AppBar(title: const Text('Bookmarks')),
            body: BlocBuilder<BookmarksBloc, BookmarksState>(
              builder: (context, state) {
                if (state.isLoading)
                  return const Center(child: CircularProgressIndicator());
                if (state.error != null)
                  return Center(child: Text(state.error!));

                final items = state.data!;
                if (items.isEmpty) {
                  return const Center(child: Text('No bookmarks yet'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final b = items[i];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),),
                      tileColor: Colors.brown.withOpacity(0.06),
                      title: Text('Surah ${b.surah} • Ayah ${b.ayah}'),
                      subtitle: Text('Saved at: ${b.savedAt}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => context
                            .read<BookmarksBloc>()
                            .add(BookmarkToggled(b.surah, b.ayah)),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahDetailPage(
                              surah: b.surah,
                              titleAr: 'Surah ${b.surah}',
                              repo: repo,
                              initialAyah: b.ayah, // jump to this verse
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
