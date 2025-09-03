import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/quran_repository.dart';
import '../bloc/surah_detail_bloc.dart';
import '../bloc/surah_detail_event.dart';
import '../bloc/surah_detail_state.dart';

/// Detail page for a given Surah.
/// - Optionally jumps to a specific verse (initialAyah).
/// - Tap an ayah: set as last read.
/// - Long-press an ayah: toggle bookmark.
class SurahDetailPage extends StatefulWidget {
  final int surah;
  final String titleAr;
  final QuranRepository repo;
  final int? initialAyah; // optional: jump to this verse index

  const SurahDetailPage({
    super.key,
    required this.surah,
    required this.titleAr,
    required this.repo,
    this.initialAyah,
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final _controller = ScrollController();

  void _scrollToInitial(int ayahCount) {
    if (widget.initialAyah == null) return;
    final index = (widget.initialAyah! - 1).clamp(0, ayahCount - 1);
    // Schedule a post-frame jump once the list is laid out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpTo(index * 72.0); // naive item height approximation
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            _scrollToInitial(ayat.length);

            return ListView.builder(
              controller: _controller,
              padding: const EdgeInsets.all(16),
              itemCount: ayat.length,
              itemBuilder: (_, i) {
                final a = ayat[i];
                return GestureDetector(
                  onTap: () {
                    // Set this ayah as the last read position
                    widget.repo.updateReadingProgress(widget.surah, a.numberInSurah);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Set last read • Surah ${widget.surah}: Ayah ${a.numberInSurah}')),
                    );
                  },
                  onLongPress: () async {
                    // Toggle bookmark for this ayah
                    await widget.repo.toggleBookmark(widget.surah, a.numberInSurah);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Toggled bookmark • Surah ${widget.surah}: Ayah ${a.numberInSurah}')),
                    );
                    setState(() {}); // refresh to reflect icon state (simple)
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.brown.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Arabic text (RTL)
                        Text(
                          '${a.textAr} ﴿${a.numberInSurah}﴾',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 22, height: 2),
                        ),
                        // TR translation if exists (LTR)
                        if (a.textTr != null && a.textTr!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(a.textTr!, textDirection: TextDirection.ltr),
                            ),
                          ),
                        const SizedBox(height: 8),
                        // Actions row (bookmark state)
                        FutureBuilder<bool>(
                          future: widget.repo.isBookmarked(widget.surah, a.numberInSurah),
                          builder: (context, snap) {
                            final isBm = snap.data ?? false;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tap: set last read • Long press: toggle bookmark',
                                    style: Theme.of(context).textTheme.bodySmall),
                                Icon(isBm ? Icons.bookmark : Icons.bookmark_outline),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
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