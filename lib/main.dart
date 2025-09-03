import 'package:flutter/material.dart';
import 'presentation/surah_list/view/surah_list_page.dart';

/// App entry point.
/// For now: Surah List -> Surah Detail navigation flow.
void main() {
  runApp(const IkraApp());
}

class IkraApp extends StatelessWidget {
  const IkraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ikra',                     // App name
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const SurahListPage(),
    );
  }
}
