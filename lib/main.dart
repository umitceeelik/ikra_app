import 'package:flutter/material.dart';
import 'presentation/home/view/home_page.dart';

/// App entry point.
/// Now starts on the Home page.
void main() {
  runApp(const IkraApp());
}

class IkraApp extends StatelessWidget {
  const IkraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ikra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}