import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/app_settings.dart';
import '../../../domain/entities/prayer_settings.dart';
import '../../settings/bloc/theme_cubit.dart';

/// Simple Settings page:
/// - Theme: Light / Sepia / Dark
/// - Arabic font: System default / AmiriQuran / KFGQPCUthmanic
/// NOTE: For custom fonts to take effect, add them in pubspec.yaml under `fonts:`.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ThemeCubit>();
    final state = context.watch<ThemeCubit>().state;
    final themeCubit = context.read<ThemeCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme selection
          Text('Tema', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<AppThemeMode>(
            segments: const [
              ButtonSegment(value: AppThemeMode.light, label: Text('Light')),
              ButtonSegment(value: AppThemeMode.sepia, label: Text('Sepia')),
              ButtonSegment(value: AppThemeMode.dark,  label: Text('Dark')),
            ],
            selected: {state.settings.themeMode},
            onSelectionChanged: (sel) => cubit.setThemeMode(sel.first),
          ),
          const SizedBox(height: 24),

          // Arabic font selection
          Text('Arapça Yazı Tipi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            value: state.settings.arabicFontFamily,
            items: const [
              DropdownMenuItem(value: null, child: Text('System Default')),
              DropdownMenuItem(value: 'AmiriQuran', child: Text('AmiriQuran')),
              DropdownMenuItem(value: 'KFGQPCUthmanicHafs', child: Text('KFGQPC Uthmanic Hafs')),
            ],
            onChanged: (v) => cubit.setArabicFontFamily(v),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Choose Arabic font (optional)',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Note: For custom fonts to work, include them under `fonts:` in pubspec.yaml and rebuild.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
