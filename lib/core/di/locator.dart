import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:ikra/core/net/connectivity_service.dart';
import 'package:ikra/data/datasources/prayer_remote_ds.dart';
import 'package:ikra/data/datasources/prayer_settings_local_ds.dart';
import 'package:ikra/data/datasources/settings_local_ds.dart';
import 'package:ikra/data/repositories/prayer_repository_impl.dart';
import 'package:ikra/data/repositories/settings_repository_impl.dart';
import 'package:ikra/domain/repositories/prayer_repository.dart';
import 'package:ikra/domain/repositories/settings_repository.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Infra
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(connectivity: sl<Connectivity>()),
  );

  // DataSources
  sl.registerLazySingleton<SettingsLocalDataSource>(() => SettingsLocalDataSource());
  sl.registerLazySingleton<PrayerSettingsLocalDataSource>(() => PrayerSettingsLocalDataSource());
  sl.registerLazySingleton<PrayerRemoteDataSource>(
    () => PrayerRemoteDataSource(client: sl<http.Client>()),
  );

  // Repositories
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl<SettingsLocalDataSource>()),
  );
  sl.registerLazySingleton<PrayerRepository>(
    () => PrayerRepositoryImpl(
      sl<PrayerSettingsLocalDataSource>(),
      sl<PrayerRemoteDataSource>(),
      sl<ConnectivityService>(),
    ),
  );
}