import 'package:flutter/material.dart';
import '../../home/view/home_page.dart';
import '../../surah_list/view/surah_list_page.dart';
import '../../bookmarks/view/bookmarks_page.dart';

/// Basic bottom-navigation shell.
/// Tab 0: Home, Tab 1: Browse (Surahs), Tab 2: Bookmarks.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    SurahListPage(),
    BookmarksPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Browse'),
          NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: 'Bookmarks'),
        ],
      ),
    );
  }
}
