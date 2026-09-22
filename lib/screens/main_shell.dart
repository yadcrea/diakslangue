import 'package:flutter/material.dart';
import '../models/language_model.dart';
import '../theme/app_colors.dart';
import 'community_screen.dart';
import 'level_screen.dart';
import 'search_screen.dart';

class MainShell extends StatefulWidget {
  final LanguageModel initialLanguage;

  const MainShell({super.key, required this.initialLanguage});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late LanguageModel _language;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  void _onLanguageChanged(LanguageModel newLanguage) {
    setState(() => _language = newLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: [
          LevelScreen(
            key: ValueKey(_language.id),
            language: _language,
            onLanguageChanged: _onLanguageChanged,
          ),
          const SearchScreen(),
          const CommunityScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.navy.withValues(alpha: 0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Leçons',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Recherche',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: 'Communauté',
          ),
        ],
      ),
    );
  }
}
