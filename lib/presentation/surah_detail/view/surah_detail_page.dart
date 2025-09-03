import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/quran_repository.dart';
import '../bloc/surah_detail_bloc.dart';

class SurahDetailPage extends StatelessWidget {
  final int surah;
  final String titleAr;
  final QuranRepository repo;
  const SurahDetailPage({super.key, required this.surah, required this.titleAr, required this.repo});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SurahDetailBloc(repo)..add(SurahDetailRequested(surah)),
      child: Scaffold(
        appBar: AppBar(title: Text(titleAr, textDirection: TextDirection.rtl)),
        body: BlocBuilder<SurahDetailBloc, SurahDetailState>(
          builder: (context, state) {
            if (state.isLoading) return const Center(child: CircularProgressIndicator());
            if (state.error != null) return Center(child: Text(state.error!));
            final ayat = state.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ayat.length,
              itemBuilder: (_, i) {
                final a = ayat[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${a.textAr} ﴿${a.numberInSurah}﴾',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontSize: 24, height: 2),
                      ),
                      if (a.textTr != null && a.textTr!.isNotEmpty)
                        Text(a.textTr!, textDirection: TextDirection.ltr),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
