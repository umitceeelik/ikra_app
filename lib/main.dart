import 'package:flutter/material.dart';
import 'presentation/surah_list/view/surah_list_page.dart';

void main() {
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ikra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const SurahListPage(),
    );
  }
}
