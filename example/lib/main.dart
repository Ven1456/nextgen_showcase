import 'package:flutter/material.dart';
import 'package:nextgen_showcase/nextgen_showcase.dart';

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
        home: ShowcaseHome(
          themeMode: _themeMode,
          onToggleThemeMode: _toggleThemeMode,
          themeData: _themeData,
          onUpdateTheme: _updateTheme,
          onEnableStunMode: () => _updateTheme(_themeData.copyWith(stunMode: true)),
          onDisableStunMode: () => _updateTheme(_themeData.copyWith(stunMode: false)),
        ),
      ),
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
      const _BasicExamplePage(),
      const _AdvancedExamplePage(),
      _PlaygroundPage(
        data: widget.themeData,
        onChanged: widget.onUpdateTheme,
      ),
      _SettingsPage(
        isDark: widget.themeMode == ThemeMode.dark,
        onToggleDark: widget.onToggleThemeMode,
        stunEnabled: widget.themeData.stunMode,
        onToggleStun: (bool v) => v ? widget.onEnableStunMode() : widget.onDisableStunMode(),
      ),
      const _EdgeCasesPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('nextgen_showcase — Examples'),
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int i) => setState(() => _index = i),
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

class _BasicExamplePage extends StatefulWidget {
  const _BasicExamplePage();

  @override
  State<_BasicExamplePage> createState() => _BasicExamplePageState();
}

class _BasicExamplePageState extends State<_BasicExamplePage> {
  final GlobalKey _buttonKey = GlobalKey();
  final NextgenShowcaseController _controller = NextgenShowcaseController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
            key: _buttonKey,
            onPressed: () {},
            child: const Text('Action button'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              _controller.setSteps(<ShowcaseStep>[
                ShowcaseStep(
                  key: _buttonKey,
                  title: 'Primary action',
                  description: 'Tap here to perform the main action.',
                ),
              ]);
              _controller.start(context);
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start tour'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _controller.dismiss,
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}

class _EdgeCasesPage extends StatefulWidget {
  const _EdgeCasesPage();

  @override
  State<_EdgeCasesPage> createState() => _EdgeCasesPageState();
}

class _EdgeCasesPageState extends State<_EdgeCasesPage> {
  final NextgenShowcaseController _controller = NextgenShowcaseController();
  final GlobalKey _unmountedKey = GlobalKey();
  final GlobalKey _farKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  Future<void> _demoMissingKey(BuildContext context) async {
    _controller.setSteps(<ShowcaseStep>[
      ShowcaseStep(
        key: _unmountedKey, // Intentionally not mounted
        title: 'Missing/moved target',
        description: 'The controller safely does nothing if the key is not found.',
      ),
    ]);
    _controller.start(context);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No crash: missing key handled gracefully')),
      );
    }
  }

  Future<void> _demoOffscreen(BuildContext context) async {
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
    _controller.setSteps(<ShowcaseStep>[
      ShowcaseStep(
        key: _farKey,
        title: 'Offscreen target',
        description: 'This button was scrolled into view before starting the tour.',
      ),
    ]);
    _controller.start(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            children: <Widget>[
              FilledButton(
                onPressed: () => _demoMissingKey(context),
                child: const Text('Missing key'),
              ),
              FilledButton.tonal(
                onPressed: () => _demoOffscreen(context),
                child: const Text('Offscreen target'),
              ),
              TextButton(
                onPressed: _controller.dismiss,
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const Text('Scroll down to find the target…'),
              const SizedBox(height: 1200),
              Center(
                child: ElevatedButton(
                  key: _farKey,
                  onPressed: () {},
                  child: const Text('Far away target'),
                ),
              ),
              const SizedBox(height: 600),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdvancedExamplePage extends StatefulWidget {
  const _AdvancedExamplePage();

  @override
  State<_AdvancedExamplePage> createState() => _AdvancedExamplePageState();
}

class _AdvancedExamplePageState extends State<_AdvancedExamplePage> {
  final GlobalKey _actionKey = GlobalKey();
  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();
  final NextgenShowcaseController _controller = NextgenShowcaseController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              key: _actionKey,
              onPressed: () {},
              child: const Text('Action button'),
            ),
            const SizedBox(height: 24),
            Card(
              key: _cardKey,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Card content'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: () {
          _controller.setSteps(<ShowcaseStep>[
            ShowcaseStep(
              key: _actionKey,
              title: 'Primary action',
              description: 'Tap here to perform the main action.',
              actions: <ShowcaseAction>[
                ShowcaseAction(label: 'Learn more', onPressed: () {}),
              ],
            ),
            ShowcaseStep(
              key: _cardKey,
              title: 'Info card',
              description: 'Details are shown here in this card.',
              contentBuilder: (BuildContext context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: const <Widget>[
                        CircleAvatar(radius: 18, backgroundImage: AssetImage('assets/demo.png')),
                        SizedBox(width: 12),
                        Text('Rich content card'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Embed images and custom widgets seamlessly.'),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        FilledButton.tonal(onPressed: () {}, child: const Text('Open link')),
                        const SizedBox(width: 8),
                        FilledButton(onPressed: () {}, child: const Text('CTA')),
                      ],
                    )
                  ],
                );
              },
            ),
            ShowcaseStep(
              key: _fabKey,
              title: 'Quick dismiss',
              description: 'Use this FAB to close the showcase at any time.',
              shape: ShowcaseShape.circle,
            ),
          ]);
          _controller.start(context);
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}

class _PlaygroundPage extends StatefulWidget {
  const _PlaygroundPage({required this.data, required this.onChanged});

  final NextgenShowcaseThemeData data;
  final void Function(NextgenShowcaseThemeData) onChanged;

  @override
  State<_PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<_PlaygroundPage> {
  final GlobalKey _targetKey = GlobalKey();
  final NextgenShowcaseController _controller = NextgenShowcaseController();
  ShowcaseShape _shape = ShowcaseShape.roundedRectangle;
  double _radius = 12;
  double _shadow = 24;
  double _backdropOpacity = 0.8;

  void _applyTheme() {
    widget.onChanged(
      widget.data.copyWith(
        backdropColor: Color(((_backdropOpacity * 255).round() << 24) | 0x000000),
        spotlightShadowBlur: _shadow,
      ),
    );
  }

  void _startDemo() {
    _controller.setSteps(<ShowcaseStep>[
      ShowcaseStep(
        key: _targetKey,
        title: 'Configurable target',
        description: 'Tweak shape, radius and shadow below.',
        shape: _shape,
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
      ),
    ]);
    if (_controller.isShowing) {
      _controller.dismiss();
      WidgetsBinding.instance.addPostFrameCallback((_) => _controller.start(context));
    } else {
      _controller.start(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              FilledButton(
                onPressed: _startDemo,
                child: const Text('Start demo'),
              ),
              const SizedBox(width: 12),
              TextButton(onPressed: _controller.dismiss, child: const Text('Dismiss')),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              DropdownButton<ShowcaseShape>(
                value: _shape,
                onChanged: (ShowcaseShape? v) {
                  setState(() => _shape = v ?? _shape);
                  if (_controller.isShowing) _startDemo();
                },
                items: const <DropdownMenuItem<ShowcaseShape>>[
                  DropdownMenuItem(value: ShowcaseShape.rectangle, child: Text('Rectangle')),
                  DropdownMenuItem(value: ShowcaseShape.roundedRectangle, child: Text('Rounded rectangle')),
                  DropdownMenuItem(value: ShowcaseShape.circle, child: Text('Circle')),
                  DropdownMenuItem(value: ShowcaseShape.oval, child: Text('Oval')),
                  DropdownMenuItem(value: ShowcaseShape.stadium, child: Text('Stadium')),
                  DropdownMenuItem(value: ShowcaseShape.diamond, child: Text('Diamond')),
                ],
              ),
              SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Border radius'),
                    Slider(
                      value: _radius,
                      min: 0,
                      max: 48,
                      label: _radius.toStringAsFixed(0),
                      onChanged: (double v) => setState(() => _radius = v),
                      onChangeEnd: (_) {
                        if (_controller.isShowing) _startDemo();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Spotlight shadow blur'),
                    Slider(
                      value: _shadow,
                      min: 0,
                      max: 48,
                      label: _shadow.toStringAsFixed(0),
                      onChanged: (double v) => setState(() => _shadow = v),
                      onChangeEnd: (_) => _applyTheme(),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Backdrop opacity'),
                    Slider(
                      value: _backdropOpacity,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      label: _backdropOpacity.toStringAsFixed(2),
                      onChanged: (double v) => setState(() => _backdropOpacity = v),
                      onChangeEnd: (_) => _applyTheme(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              key: _targetKey,
              onPressed: () {},
              child: const Text('Target widget'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({
    required this.isDark,
    required this.onToggleDark,
    required this.stunEnabled,
    required this.onToggleStun,
  });

  final bool isDark;
  final void Function(bool) onToggleDark;
  final bool stunEnabled;
  final void Function(bool) onToggleStun;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        SwitchListTile(
          title: const Text('Dark mode'),
          value: isDark,
          onChanged: onToggleDark,
        ),
        SwitchListTile(
          title: const Text('Stun Mode (animated gradient + glass)'),
          value: stunEnabled,
          onChanged: onToggleStun,
        ),
        const ListTile(
          title: Text('About'),
          subtitle: Text('This example showcases multiple use cases and a live playground.'),
        ),
      ],
    );
  }
}

