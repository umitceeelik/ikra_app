import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikra/core/app_theme.dart';
import 'package:ikra/core/bootstrap.dart';
import 'package:ikra/core/di/locator.dart';
import 'package:ikra/domain/entities/app_settings.dart';
import 'package:ikra/domain/repositories/settings_repository.dart';
import 'package:ikra/presentation/root/view/root_shell.dart';
import 'package:ikra/presentation/settings/bloc/theme_cubit.dart';

/// App entry point with bootstrap + global ThemeCubit provided from DI.
Future<void> main() async {
  await bootstrap(); // Hive + boxes + locator

  runApp(
    BlocProvider(
      create: (_) => ThemeCubit(sl<SettingsRepository>()),
      child: const IkraApp(),
    ),
  );
}

class IkraApp extends StatelessWidget {
  const IkraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final theme = switch (state.settings.themeMode) {
          AppThemeMode.light => AppTheme.light(),
          AppThemeMode.sepia => AppTheme.sepia(),
          AppThemeMode.dark => AppTheme.dark(),
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
