import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikra/core/app_theme.dart';
// NEW: audio imports
import 'package:ikra/data/audio/audio_url_provider.dart';
import 'package:ikra/domain/repositories/quran_repository.dart';
import 'package:ikra/presentation/audio/cubit/surah_audio_cubit.dart';
import 'package:ikra/presentation/settings/bloc/theme_cubit.dart';
import 'package:ikra/presentation/surah_detail/bloc/surah_detail_bloc.dart';
import 'package:ikra/presentation/surah_detail/bloc/surah_detail_event.dart';
import 'package:ikra/presentation/surah_detail/bloc/surah_detail_state.dart';

/// Detail page for a given Surah.
/// - Optionally jumps to a specific verse (initialAyah).
/// - Tap an ayah: set as last read.
/// - Long-press an ayah: toggle bookmark.
/// - NEW: Audio mini-player (play/pause/next/prev). Tap an ayah to start from it.
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

  // NEW: hold audio cubit to avoid re-creating on rebuilds
  SurahAudioCubit? _audio;

  void _scrollToInitial(int ayahCount) {
    if (widget.initialAyah == null) return;
    final index = (widget.initialAyah! - 1).clamp(0, ayahCount - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpTo(index * 72.0); // naive item height approximation
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audio?.dispose(); // NEW: dispose audio
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SurahDetailBloc(widget.repo)..add(SurahDetailRequested(widget.surah)),
      child: Scaffold(
        appBar: AppBar(
            title: Text(widget.titleAr, textDirection: TextDirection.rtl),),
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

            // NEW: lazy-create the audio cubit once we know ayah count
            _audio ??= SurahAudioCubit(
              urlProvider: AudioUrlProvider(),
              surah: widget.surah,
            );
            // If playlist not loaded yet, load it
            if (_audio!.state.totalAyah != ayat.length) {
              _audio!.load(totalAyah: ayat.length);
            }

            return StreamBuilder<SurahAudioState>(
              stream: _audio!.stream,
              initialData: _audio!.state,
              builder: (context, snap) {
                final audio = snap.data!;

                return Stack(
                  children: [
                    ListView.builder(
                      controller: _controller,
                      padding: const EdgeInsets.fromLTRB(
                          16, 16, 16, 100,), // extra bottom for mini-player
                      itemCount: ayat.length,
                      itemBuilder: (_, i) {
                        final a = ayat[i];
                        final isPlayingHere =
                            (audio.currentAyah == a.numberInSurah) &&
                                audio.isPlaying;

                        return GestureDetector(
                          onTap: () {
                            // Set this ayah as the last read position
                            widget.repo.updateReadingProgress(
                                widget.surah, a.numberInSurah,);
                            // Start audio from this ayah
                            _audio!.playFrom(a.numberInSurah);
                          },
                          onLongPress: () async {
                            await widget.repo
                                .toggleBookmark(widget.surah, a.numberInSurah);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Yer imi değişti • ${widget.surah}:${a.numberInSurah}',),),
                            );
                            setState(
                                () {},); // refresh small state (bookmark icon)
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isPlayingHere
                                  ? Colors.green.withOpacity(
                                      0.12,) // highlight currently playing
                                  : Colors.brown.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Arabic text (RTL) with selected font
                                Text(
                                  '${a.textAr} ﴿${a.numberInSurah}﴾',
                                  textDirection: TextDirection.rtl,
                                  style: AppTheme.arabic(
                                    fontFamily: context
                                        .read<ThemeCubit>()
                                        .state
                                        .settings
                                        .arabicFontFamily,
                                  ).copyWith(fontSize: 24),
                                ),
                                // TR translation if exists (LTR)
                                if (a.textTr != null && a.textTr!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(a.textTr!,
                                          textDirection: TextDirection.ltr,),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                // Row: small hint + bookmark state (async check)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Dokun: buradan oynat • Uzun bas: yer imi',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Icon(isPlayingHere
                                        ? Icons.equalizer
                                        : Icons.play_arrow_rounded,),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // NEW: Mini player anchored to bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _MiniPlayer(
                        isLoading: audio.isLoading,
                        isPlaying: audio.isPlaying,
                        current: audio.currentAyah ?? 1,
                        total: audio.totalAyah,
                        onPrev: _audio!.previous,
                        onNext: _audio!.next,
                        onToggle: _audio!.togglePlayPause,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Simple bottom mini player with prev / play-pause / next.
/// Keeps UI minimal and safe for rebuilds.
class _MiniPlayer extends StatelessWidget {
  final bool isLoading;
  final bool isPlaying;
  final int current;
  final int total;
  final Future<void> Function() onPrev;
  final Future<void> Function() onNext;
  final Future<void> Function() onToggle;

  const _MiniPlayer({
    required this.isLoading,
    required this.isPlaying,
    required this.current,
    required this.total,
    required this.onPrev,
    required this.onNext,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Önceki',
              onPressed: isLoading ? null : () => onPrev(),
              icon: const Icon(Icons.skip_previous_rounded),
            ),
            IconButton(
              tooltip: isPlaying ? 'Duraklat' : 'Oynat',
              onPressed: isLoading ? null : () => onToggle(),
              icon: Icon(isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,),
              iconSize: 36,
            ),
            IconButton(
              tooltip: 'Sonraki',
              onPressed: isLoading ? null : () => onNext(),
              icon: const Icon(Icons.skip_next_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isLoading ? 'Hazırlanıyor...' : 'Sûre • Ayet $current / $total',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
