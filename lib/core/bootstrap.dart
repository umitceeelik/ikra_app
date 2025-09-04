import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ikra/core/di/locator.dart';
import 'package:ikra/core/hive_boxes.dart';
import 'package:ikra/data/models/app_settings.dart';
import 'package:ikra/data/models/prayer_settings.dart';

/// Initializes frameworks (Hive), opens boxes, and sets up the service locator.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register adapters
  await Hive.initFlutter();
  Hive.registerAdapter(AppSettingsHiveAdapter());
  Hive.registerAdapter(PrayerSettingsHiveAdapter());

  // Open boxes once at startup (singletons)
  await Hive.openBox<AppSettingsHive>(HiveBoxes.settings);
  await Hive.openBox<PrayerSettingsHive>(HiveBoxes.prayerSettings);

  // Register dependencies
  await setupLocator();
}
