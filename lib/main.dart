import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'domain/entities/app_settings.dart';
import 'presentation/root/view/root_shell.dart';
import 'core/app_theme.dart';

// Settings wiring
import 'data/datasources/settings_local_ds.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/settings_repository.dart';
import 'presentation/settings/bloc/theme_cubit.dart';

/// App entry point: now uses a bottom-navigation shell.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

   // Initialize settings storage before running the app
  final settingsLocal = SettingsLocalDataSource();
  await settingsLocal.init();
  final SettingsRepository settingsRepo = SettingsRepositoryImpl(settingsLocal);

  runApp(
    RepositoryProvider.value(
      value: settingsRepo,
      child: BlocProvider(
        create: (_) => ThemeCubit(settingsRepo),
        child: const IkraApp(),
      ),
    ),
  );
}

class IkraApp extends StatelessWidget {
  const IkraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        // Map theme mode to a ThemeData
        final mode = state.settings.themeMode;
        final theme = switch (mode) {
          AppThemeMode.light => AppTheme.light(),
          AppThemeMode.sepia => AppTheme.sepia(),
          AppThemeMode.dark  => AppTheme.dark(),
        };
        return MaterialApp(
          title: 'ikra',
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const RootShell(),
        );
      },
    );
  }
}