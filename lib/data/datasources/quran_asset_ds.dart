import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Reads the bundled JSON from assets and returns it as a Map.
/// Purpose: enable an offline-first bootstrap without network.
class QuranAssetDataSource {
  Future<Map<String, dynamic>> loadJson() async {
    // Path must match the entry in pubspec.yaml -> flutter.assets
    final raw = await rootBundle.loadString('assets/quran/quran.json');
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
