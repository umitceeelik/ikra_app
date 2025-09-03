import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/quran_repository.dart';
import '../bloc/surah_detail_bloc.dart';
import '../bloc/surah_detail_event.dart';
import '../bloc/surah_detail_state.dart';

/// Detail page for a given Surah.
/// On first frame, we store a simple reading progress (Surah, Ayah 1).
class SurahDetailPage extends StatefulWidget {
  final int surah;
  final String titleAr;
  final QuranRepository repo;

  const SurahDetailPage({
    super.key,
    required this.surah,
    required this.titleAr,
    required this.repo,
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  @override
  void initState() {
    super.initState();
    // Post-frame callback ensures this runs once after the first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.repo.updateReadingProgress(widget.surah, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SurahDetailBloc(widget.repo)..add(SurahDetailRequested(widget.surah)),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.titleAr, textDirection: TextDirection.rtl)),
        body: BlocBuilder<SurahDetailBloc, SurahDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text(state.error!));
            }

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
                      // Arabic text (RTL)
                      Text(
                        '${a.textAr} ﴿${a.numberInSurah}﴾',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontSize: 24, height: 2),
                      ),
                      // If a Turkish translation exists, render it below (LTR)
                      if (a.textTr != null && a.textTr!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(a.textTr!, textDirection: TextDirection.ltr),
                        ),
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