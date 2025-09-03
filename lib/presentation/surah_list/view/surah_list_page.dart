import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/quran_asset_ds.dart';
import '../../../data/datasources/quran_local_ds.dart';
import '../../../data/repositories/quran_repository_impl.dart';
import '../../../domain/repositories/quran_repository.dart';
import '../../surah_detail/view/surah_detail_page.dart';
import '../bloc/surah_list_bloc.dart';
import '../bloc/surah_list_event.dart';
import '../bloc/surah_list_state.dart';

/// Page flow:
/// - Wait for Hive initialization (FutureBuilder).
/// - Provide the BLoC.
/// - Dispatch SurahListRequested on open.
/// - Render loading/error/data accordingly.
class SurahListPage extends StatelessWidget {
  const SurahListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final local = QuranLocalDataSource();
    final asset = QuranAssetDataSource();
    final QuranRepository repo = QuranRepositoryImpl(local: local, asset: asset);

    return FutureBuilder(
      future: local.init(), // 1) Initialize Hive (register adapters & open boxes)
      builder: (context, snapshot) {
        // Do not build the page until Hive is ready
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2) Provide the BLoC once Hive is initialized
        return BlocProvider(
          create: (_) => SurahListBloc(repo)..add(SurahListRequested()),
          child: Scaffold(
            appBar: AppBar(title: const Text('القرآن الكريم')),
            body: BlocBuilder<SurahListBloc, SurahListState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(child: Text(state.error!));
                }

                final list = state.data!;
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final s = list[i];
                    return ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      tileColor: Colors.brown.withOpacity(0.06),
                      title: Text(
                        s.nameAr,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontSize: 20),
                      ),
                      subtitle: Text('${s.nameEn} • ${s.nameTr} • ${s.ayahCount} ayet'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahDetailPage(
                              surah: s.number,
                              titleAr: s.nameAr,
                              repo: repo, // reuse the same repository instance
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
