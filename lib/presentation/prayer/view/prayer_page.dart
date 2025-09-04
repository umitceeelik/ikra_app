import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/prayer_settings_local_ds.dart';
import '../../../data/repositories/prayer_repository_impl.dart';
import '../../../domain/repositories/prayer_repository.dart';
import '../../../domain/entities/prayer_settings.dart';

import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../bloc/prayer_state.dart';

/// Prayer times page:
/// - Requests location on first open
/// - Can compute locally (adhan_dart) or fetch from Diyanet (online via AlAdhan)
/// - Shows a data source switch + method/madhab controls
/// - Uses Builder to read BLoC under the provider (avoids ProviderNotFoundException)
class PrayerPage extends StatelessWidget {
  const PrayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Wire repository quickly; can be moved to a DI layer later.
    final local = PrayerSettingsLocalDataSource();

    return FutureBuilder(
      // Initialize local Hive storage for prayer settings
      future: local.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final PrayerRepository repo = PrayerRepositoryImpl(local);

        return BlocProvider(
          create: (_) => PrayerBloc(repo)..add(PrayerRequested()),
          // Create a new BuildContext under the BlocProvider
          child: Builder(
            builder: (innerCtx) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Ezan Vakitleri'),
                  actions: [
                    IconButton(
                      tooltip: 'Yenile',
                      // IMPORTANT: use innerCtx (under BlocProvider)
                      onPressed: () => innerCtx.read<PrayerBloc>().add(PrayerRequested()),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                body: BlocBuilder<PrayerBloc, PrayerState>(
                  builder: (innerCtx, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.error != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Hata: ${state.error!}\n\nLütfen konum iznini verip tekrar deneyin.'),
                        ),
                      );
                    }

                    final s = state.settings!;
                    final t = state.times!;
                    final now = DateTime.now();
                    final next = t.nextPrayer(now);

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Next prayer highlight
                        if (next != null)
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.access_time),
                              title: Text('Sıradaki: ${next.$1}'),
                              subtitle: Text(TimeOfDay.fromDateTime(next.$2).format(innerCtx)),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Today times
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                _timeRow(innerCtx, 'Fajr', t.fajr),
                                const Divider(height: 16),
                                _timeRow(innerCtx, 'Sunrise', t.sunrise),
                                const Divider(height: 16),
                                _timeRow(innerCtx, 'Dhuhr', t.dhuhr),
                                const Divider(height: 16),
                                _timeRow(innerCtx, 'Asr', t.asr),
                                const Divider(height: 16),
                                _timeRow(innerCtx, 'Maghrib', t.maghrib),
                                const Divider(height: 16),
                                _timeRow(innerCtx, 'Isha', t.isha),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Data source selection (Local vs Diyanet online)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Veri Kaynağı', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                SegmentedButton<PrayerSource>(
                                  segments: const [
                                    ButtonSegment(
                                      value: PrayerSource.localCalc,
                                      label: Text('Yerel Hesap'),
                                    ),
                                    ButtonSegment(
                                      value: PrayerSource.diyanetOnline,
                                      label: Text('Diyanet (Online)'),
                                    ),
                                  ],
                                  selected: {s.source},
                                  onSelectionChanged: (sel) =>
                                      innerCtx.read<PrayerBloc>().add(PrayerSourceChanged(sel.first)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s.source == PrayerSource.diyanetOnline
                                      ? 'Resmi Diyanet saatleri (internet gerekir).'
                                      : 'Cihaz üzerinde hesaplama (internet gerekmez).',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Settings card (conditional UI)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // When localCalc: show both Method + Madhab controls
                                if (s.source == PrayerSource.localCalc) ...[
                                  Text('Hesaplama Yöntemi', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<CalcMethod>(
                                    value: s.method,
                                    items: const [
                                      DropdownMenuItem(value: CalcMethod.muslimWorldLeague, child: Text('MWL')),
                                      DropdownMenuItem(value: CalcMethod.egyptian, child: Text('Egyptian')),
                                      DropdownMenuItem(value: CalcMethod.karachi, child: Text('Karachi')),
                                      DropdownMenuItem(value: CalcMethod.ummAlQura, child: Text('Umm al-Qura')),
                                      DropdownMenuItem(value: CalcMethod.dubai, child: Text('Dubai')),
                                      DropdownMenuItem(value: CalcMethod.qatar, child: Text('Qatar')),
                                      DropdownMenuItem(value: CalcMethod.kuwait, child: Text('Kuwait')),
                                      DropdownMenuItem(value: CalcMethod.northAmerica, child: Text('North America')),
                                      DropdownMenuItem(value: CalcMethod.moonsightingCommittee, child: Text('Moonsighting Committee')),
                                    ],
                                    onChanged: (m) {
                                      if (m == null) return;
                                      // Update only method; keep madhab unchanged
                                      innerCtx.read<PrayerBloc>().add(PrayerSettingsChanged(m, s.madhab));
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text('Mezhep (Asr)', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  SegmentedButton<Madhab>(
                                    segments: const [
                                      ButtonSegment(value: Madhab.shafi, label: Text('Shafi')),
                                      ButtonSegment(value: Madhab.hanafi, label: Text('Hanafi')),
                                    ],
                                    selected: {s.madhab},
                                    onSelectionChanged: (sel) => innerCtx
                                        .read<PrayerBloc>()
                                        .add(PrayerSettingsChanged(s.method, sel.first)),
                                  ),
                                ] else ...[
                                  // When Diyanet online: only Madhab (maps to API "school" param)
                                  Text('Mezhep (Asr)', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  SegmentedButton<Madhab>(
                                    segments: const [
                                      ButtonSegment(value: Madhab.shafi, label: Text('Shafi')),
                                      ButtonSegment(value: Madhab.hanafi, label: Text('Hanafi')),
                                    ],
                                    selected: {s.madhab},
                                    onSelectionChanged: (sel) => innerCtx
                                        .read<PrayerBloc>()
                                        // Keep current method unchanged; source is already Diyanet
                                        .add(PrayerSettingsChanged(s.method, sel.first)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Diyanet verisinde mezhep sadece Asr vakti hesabını etkiler.',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],

                                const SizedBox(height: 12),
                                Text(
                                  s.hasLocation
                                      ? 'Konum: ${s.latitude!.toStringAsFixed(4)}, ${s.longitude!.toStringAsFixed(4)}'
                                        ' • Kaynak: ${s.source.name} • Yöntem: ${s.method.name} • Mezhep: ${s.madhab.name}'
                                      : 'Konum yok (ilk açılışta izin istenir)',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Helper to render a single timing row with local time format.
  Widget _timeRow(BuildContext context, String name, DateTime dt) {
    return Row(
      children: [
        Expanded(child: Text(name)),
        Text(TimeOfDay.fromDateTime(dt).format(context)),
      ],
    );
  }
}