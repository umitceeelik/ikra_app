import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QuranAssetDataSource {
  Future<Map<String, dynamic>> loadJson() async {
    final raw = await rootBundle.loadString('assets/quran/quran.json');
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
