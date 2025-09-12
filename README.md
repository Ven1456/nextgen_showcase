## nextgen_showcase

A modern, lightweight Flutter package to create guided product tours and spotlight walkthroughs in minutes.

[![Pub Version](https://img.shields.io/pub/v/nextgen_showcase.svg)](https://pub.dev/packages/nextgen_showcase)
[![CI](https://github.com/Ven1456/nextgen_showcase.git)

[//]: # ([![codecov]&#40;https://codecov.io/gh/your-org/nextgen_showcase/branch/main/graph/badge.svg&#41;]&#40;https://app.codecov.io/gh/your-org/nextgen_showcase&#41;)

[//]: # (### Demo)

[//]: # ()
[//]: # (https://github.com/your-org/nextgen_showcase/assets/demo.gif)

[//]: # (- Add a short GIF or link a YouTube demo above. Replace the placeholder with your assets.)

### Features
- ✅ Frosted backdrop with spotlight cutout (rectangle, rounded, circle)
- ✅ Material 3 card with title, description, and actions
- ✅ Simple, controller-driven API (start/next/previous/dismiss)
- ✅ Theming via `NextgenShowcaseTheme`
- ✅ Works on mobile, web, and desktop

### Installation
Add to your `pubspec.yaml`:

```yaml
dependencies:
  nextgen_showcase: ^0.1.5
```

Then run:

```bash
flutter pub get
```

### Quick start
```dart
import 'package:flutter/material.dart';
import 'package:nextgen_showcase/nextgen_showcase.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: DemoPage(), debugShowCheckedModeBanner: false);
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});
  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final GlobalKey _buttonKey = GlobalKey();
  final NextgenShowcaseController _controller = NextgenShowcaseController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nextgen Showcase')),
      body: Center(
        child: ElevatedButton(
          key: _buttonKey,
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
          child: const Text('Showcase me'),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _controller.dismiss, child: const Icon(Icons.close)),
    );
  }
}
```

### Advanced usage

```dart
NextgenShowcaseTheme(
  data: const NextgenShowcaseThemeData(
    backdropColor: Color(0xCC000000),
    spotlightShadowBlur: 28,
  ),
  child: YourApp(),
);
```

### Example app
See `example/` for a runnable demo with multiple steps and actions.

[//]: # (### Roadmap)

[//]: # (- [ ] Async step actions &#40;e.g., open links&#41;)

[//]: # (- [ ] Auto-positioning of info card &#40;above/below target&#41;)

[//]: # (- [ ] A11y: focus trap and screen reader labels)

### Contributing
Contributions are welcome! Please open an issue or PR.

### License
MIT
