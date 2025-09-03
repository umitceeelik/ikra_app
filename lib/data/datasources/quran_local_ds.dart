import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../models/ayah.dart';
import '../models/surah.dart';
import '../../core/hive_boxes.dart';

class QuranLocalDataSource {
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SurahHiveAdapter());
    Hive.registerAdapter(AyahHiveAdapter());
    await Hive.openBox<SurahHive>(HiveBoxes.surahs);
    await Hive.openBox<AyahHive>(HiveBoxes.ayahs);
  }

  bool isEmpty() {
    final s = Hive.box<SurahHive>(HiveBoxes.surahs);
    final a = Hive.box<AyahHive>(HiveBoxes.ayahs);
    return s.isEmpty || a.isEmpty;
  }

  Future<void> writeAll({
    required List<SurahHive> surahs,
    required List<AyahHive> ayahs,
  }) async {
    final s = Hive.box<SurahHive>(HiveBoxes.surahs);
    final a = Hive.box<AyahHive>(HiveBoxes.ayahs);
    await s.clear();
    await a.clear();
    await s.addAll(surahs);
    await a.addAll(ayahs);
  }

  List<Surah> getSurahList() {
    final s = Hive.box<SurahHive>(HiveBoxes.surahs);
    return s.values.map((e) => e.toEntity()).toList()
      ..sort((a,b) => a.number.compareTo(b.number));
  }

  List<Ayah> getAyatBySurah(int surah) {
    final a = Hive.box<AyahHive>(HiveBoxes.ayahs);
    final list = a.values.where((x) => x.surah == surah).toList()
      ..sort((p,q) => p.numberInSurah.compareTo(q.numberInSurah));
    return list.map((e) => e.toEntity()).toList();
  }
}
