import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/quran_asset_ds.dart';
import '../../../data/datasources/quran_local_ds.dart';
import '../../../data/repositories/quran_repository_impl.dart';
import '../../../domain/repositories/quran_repository.dart';
import '../../surah_list/view/surah_list_page.dart';
import '../../surah_detail/view/surah_detail_page.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

/// Simple Home screen with:
/// - Continue Reading card (if progress exists)
/// - Verse of the Day card
/// - Browse Surahs button
/// - Prayer Times placeholder card
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // For simplicity we wire the repo here (you can move to DI later).
    final local = QuranLocalDataSource();
    final asset = QuranAssetDataSource();
    final QuranRepository repo = QuranRepositoryImpl(local: local, asset: asset);

    return FutureBuilder(
      future: local.init(), // Initialize Hive before using it on Home
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return BlocProvider(
          create: (_) => HomeBloc(repo)..add(HomeRequested()),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Ikra Home'),
            ),
            body: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(child: Text(state.error!));
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Continue Reading card
                    if (state.progress != null)
                      _ContinueReadingCard(
                        surah: state.progress!.surah,
                        ayah: state.progress!.ayah,
                        onOpen: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SurahDetailPage(
                                surah: state.progress!.surah,
                                titleAr: 'Continue',
                                repo: repo,
                              ),
                            ),
                          );
                        },
                      )
                    else
                      _EmptyContinueCard(onBrowse: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SurahListPage()),
                        );
                      }),

                    const SizedBox(height: 16),

                    // Verse of the Day (Arabic only for now)
                    if (state.verseOfTheDay != null)
                      _VerseOfTheDayCard(
                        arabic: state.verseOfTheDay!.textAr,
                        surah: state.verseOfTheDay!.surah,
                        ayah: state.verseOfTheDay!.numberInSurah,
                      ),

                    const SizedBox(height: 16),

                    // Prayer Times placeholder
                    _PrayerTimesPlaceholder(),

                    const SizedBox(height: 16),

                    // Browse Surahs button
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SurahListPage()),
                        );
                      },
                      icon: const Icon(Icons.menu_book),
                      label: const Text('Browse Surahs'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Compact card prompting user to continue where they left off.
class _ContinueReadingCard extends StatelessWidget {
  final int surah;
  final int ayah;
  final VoidCallback onOpen;

  const _ContinueReadingCard({
    required this.surah,
    required this.ayah,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.bookmark, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Continue reading • Surah $surah : Ayah $ayah'),
            ),
            const SizedBox(width: 12),
            FilledButton(onPressed: onOpen, child: const Text('Open')),
          ],
        ),
      ),
    );
  }
}

/// Shown when there is no reading progress yet.
class _EmptyContinueCard extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyContinueCard({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.explore, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Start reading the Qur\'an — pick a Surah to begin'),
            ),
            const SizedBox(width: 12),
            FilledButton(onPressed: onBrowse, child: const Text('Browse')),
          ],
        ),
      ),
    );
  }
}

/// Verse-of-the-day card, Arabic text with simple metadata.
class _VerseOfTheDayCard extends StatelessWidget {
  final String arabic;
  final int surah;
  final int ayah;

  const _VerseOfTheDayCard({
    required this.arabic,
    required this.surah,
    required this.ayah,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$arabic ﴿$ayah﴾',
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 22, height: 2),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Surah $surah • Ayah $ayah'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder card for Prayer Times (to wire later with location & calc method).
class _PrayerTimesPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text('Prayer times • Set your location (coming soon)'),
            ),
          ],
        ),
      ),
    );
  }
}
