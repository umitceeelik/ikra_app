import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/quran_asset_ds.dart';
import '../../../data/datasources/quran_local_ds.dart';
import '../../../data/repositories/quran_repository_impl.dart';
import '../../../domain/repositories/quran_repository.dart';
import '../bloc/surah_list_bloc.dart';
import '../../surah_detail/view/surah_detail_page.dart';

class SurahListPage extends StatelessWidget {
  const SurahListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final local = QuranLocalDataSource();
    final asset = QuranAssetDataSource();
    final repo = QuranRepositoryImpl(local: local, asset: asset);

    return FutureBuilder(
      future: local.init(), // Hive'i aç, adapterları kaydet
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return BlocProvider(
          create: (_) => SurahListBloc(repo)..add(SurahListRequested()),
          child: Scaffold(
            appBar: AppBar(title: const Text('القرآن الكريم')),
            body: BlocBuilder<SurahListBloc, SurahListState>(
              builder: (context, state) {
                if (state.isLoading) return const Center(child: CircularProgressIndicator());
                if (state.error != null) return Center(child: Text(state.error!));

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
                      title: Text(s.nameAr, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 20)),
                      subtitle: Text('${s.nameEn} • ${s.nameTr} • ${s.ayahCount} ayet'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SurahDetailPage(surah: s.number, titleAr: s.nameAr, repo: repo)),
                      ),
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
