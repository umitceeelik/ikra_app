import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikra/core/di/locator.dart';
import 'package:ikra/domain/entities/prayer_settings.dart';
import 'package:ikra/domain/repositories/prayer_repository.dart';
import 'package:ikra/presentation/prayer/bloc/prayer_bloc.dart';
import 'package:ikra/presentation/prayer/bloc/prayer_event.dart';
import 'package:ikra/presentation/prayer/bloc/prayer_state.dart';

/// Prayer times page (DI-based):
/// - Repository is obtained from service locator
/// - No local init/box open here (bootstrap handles it)
/// - Builder ensures context is under BlocProvider for read/watch calls
class PrayerPage extends StatelessWidget {
  const PrayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = sl<PrayerRepository>(); // get from DI

    return BlocProvider(
      create: (_) => PrayerBloc(repo)..add(PrayerRequested()),
      child: Builder(
        builder: (innerCtx) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Ezan Vakitleri'),
              actions: [
                IconButton(
                  tooltip: 'Yenile',
                  onPressed: () =>
                      innerCtx.read<PrayerBloc>().add(PrayerRequested()),
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
                  final err = state.error!;
                  final isNoInternet = err.contains('NO_INTERNET');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              isNoInternet
                                  ? Icons.wifi_off
                                  : Icons.error_outline,
                              size: 48),
                          const SizedBox(height: 12),
                          Text(
                            isNoInternet
                                ? 'İnternet bağlantısı gerekir'
                                : 'Beklenmeyen bir hata oluştu',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isNoInternet
                                ? 'Namaz vakitleri çevrimiçi kaynaktan alınır. Lütfen interneti açıp tekrar deneyin.'
                                : err,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => innerCtx
                                .read<PrayerBloc>()
                                .add(PrayerRequested()),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
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
                    if (next != null)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text('Sıradaki: ${next.$1}'),
                          subtitle: Text(
                            TimeOfDay.fromDateTime(next.$2).format(innerCtx),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

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

                    // Info: data source is always online now
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Veri Kaynağı',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            const Text(
                                'Diyanet (Online) — Konumunuza göre çekilir.'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Settings: only Madhab (Asr)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mezhep (Asr)',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            SegmentedButton<Madhab>(
                              segments: const [
                                ButtonSegment(
                                    value: Madhab.shafi, label: Text('Shafi')),
                                ButtonSegment(
                                    value: Madhab.hanafi,
                                    label: Text('Hanafi')),
                              ],
                              selected: {s.madhab},
                              onSelectionChanged: (sel) => innerCtx
                                  .read<PrayerBloc>()
                                  .add(PrayerSettingsChanged(s.method,
                                      sel.first)), // method is ignored now
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
          );
        },
      ),
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
