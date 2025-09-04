import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/prayer_settings_local_ds.dart';
import '../../../data/repositories/prayer_repository_impl.dart';
import '../../../domain/repositories/prayer_repository.dart';
import '../../../domain/entities/prayer_settings.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../bloc/prayer_state.dart';

/// Renders today's prayer times and allows changing calc method / madhab.
/// Requests location permission on first open and stores coordinates locally.
class PrayerPage extends StatelessWidget {
  const PrayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Wire repository quickly (can be moved to DI later if desired).
    final local = PrayerSettingsLocalDataSource();

    return FutureBuilder(
      future: local.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final PrayerRepository repo = PrayerRepositoryImpl(local);

        return BlocProvider(
          create: (_) => PrayerBloc(repo)..add(PrayerRequested()),
          child: Scaffold(
            appBar: AppBar(title: const Text('Ezan Vakitleri')),
            body: BlocBuilder<PrayerBloc, PrayerState>(
              builder: (context, state) {
                if (state.isLoading) return const Center(child: CircularProgressIndicator());
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
                          subtitle: Text(TimeOfDay.fromDateTime(next.$2).format(context)),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Today times
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            _timeRow(context, 'Fajr', t.fajr),
                            const Divider(height: 16),
                            _timeRow(context, 'Sunrise', t.sunrise),
                            const Divider(height: 16),
                            _timeRow(context, 'Dhuhr', t.dhuhr),
                            const Divider(height: 16),
                            _timeRow(context, 'Asr', t.asr),
                            const Divider(height: 16),
                            _timeRow(context, 'Maghrib', t.maghrib),
                            const Divider(height: 16),
                            _timeRow(context, 'Isha', t.isha),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Settings (method & madhab)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                DropdownMenuItem(value: CalcMethod.turkiye, child: Text('Türkiye Committee')),
                              ],
                              onChanged: (m) {
                                if (m == null) return;
                                context.read<PrayerBloc>().add(PrayerSettingsChanged(m, s.madhab));
                              },
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
                              onSelectionChanged: (sel) {
                                context.read<PrayerBloc>().add(
                                  PrayerSettingsChanged(s.method, sel.first),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Text(
                              s.hasLocation
                                  ? 'Konum: ${s.latitude!.toStringAsFixed(4)}, ${s.longitude!.toStringAsFixed(4)}'
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
          ),
        );
      },
    );
  }

  /// Render a name-time row using local time formatting.
  Widget _timeRow(BuildContext context, String name, DateTime dt) {
    return Row(
      children: [
        Expanded(child: Text(name)),
        Text(TimeOfDay.fromDateTime(dt).format(context)),
      ],
    );
  }
}
