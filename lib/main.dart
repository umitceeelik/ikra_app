import 'package:flutter/material.dart';
import 'presentation/root/view/root_shell.dart';

/// App entry point: now uses a bottom-navigation shell.
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
      home: const RootShell(),
    );
  }
}