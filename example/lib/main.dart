import 'package:flutter/material.dart';
import 'package:nextgen_showcase/nextgen_showcase.dart';
import 'screens/basic_example_page.dart';
import 'screens/advanced_example_page.dart';
import 'screens/playground_page.dart';
import 'screens/settings_page.dart';
import 'screens/edge_cases_page.dart';

void main() {
  runApp(const ShowcaseExampleApp());
}

class ShowcaseExampleApp extends StatefulWidget {
  const ShowcaseExampleApp({super.key});

  @override
  State<ShowcaseExampleApp> createState() => _ShowcaseExampleAppState();
}

class _ShowcaseExampleAppState extends State<ShowcaseExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;
  NextgenShowcaseThemeData _themeData = const NextgenShowcaseThemeData();

  void _updateTheme(NextgenShowcaseThemeData data) {
    setState(() {
      _themeData = data;
    });
  }

  void _toggleThemeMode(bool dark) {
    setState(() {
      _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NextgenShowcaseTheme(
      data: _themeData,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
        darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        // Use a single, simple demo page to keep the exHomee minimal and robust.
        home: ShowcaseHome(
          themeMode: _themeMode,
          onToggleThemeMode: _toggleThemeMode,
          themeData: _themeData,
          onUpdateTheme: _updateTheme,
          onEnableStunMode: () =>
              _updateTheme(_themeData.copyWith(stunMode: true)),
          onDisableStunMode: () =>
              _updateTheme(_themeData.copyWith(stunMode: false)),
        ),      ),
    );
  }
}

class ShowcaseHome extends StatefulWidget {
  const ShowcaseHome({
    super.key,
    required this.themeMode,
    required this.onToggleThemeMode,
    required this.themeData,
    required this.onUpdateTheme,
    required this.onEnableStunMode,
    required this.onDisableStunMode,
  });

  final ThemeMode themeMode;
  final void Function(bool dark) onToggleThemeMode;
  final NextgenShowcaseThemeData themeData;
  final void Function(NextgenShowcaseThemeData) onUpdateTheme;
  final VoidCallback onEnableStunMode;
  final VoidCallback onDisableStunMode;

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const BasicExamplePage(),
      const AdvancedExamplePage(),
      PlaygroundPage(
        data: widget.themeData,
        onChanged: widget.onUpdateTheme,
      ),
      SettingsPage(
        isDark: widget.themeMode == ThemeMode.dark,
        onToggleDark: widget.onToggleThemeMode,
        stunEnabled: widget.themeData.stunMode,
        onToggleStun: (bool v) => v ? widget.onEnableStunMode() : widget.onDisableStunMode(),
      ),
      const EdgeCasesPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('nextgen_showcase — Examples'),
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int i) {
          // Close any active showcase when switching tabs
          ShowcaseManager().dismissActive();
          setState(() => _index = i);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.play_arrow_outlined), selectedIcon: Icon(Icons.play_arrow), label: 'Basic'),
          NavigationDestination(icon: Icon(Icons.star_border), selectedIcon: Icon(Icons.star), label: 'Advanced'),
          NavigationDestination(icon: Icon(Icons.tune), selectedIcon: Icon(Icons.tune), label: 'Playground'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
          NavigationDestination(icon: Icon(Icons.report_gmailerrorred_outlined), selectedIcon: Icon(Icons.report), label: 'Edge cases'),
        ],
      ),
    );
  }
}