## nextgen_showcase

Modern Flutter showcase/tour widget adopting latest UI trends.

### Features
- Highlight target widgets with frosted overlay and focus ring
- Title/description card with Material 3 styling
- Simple controller-driven API

### Installation
Add to your `pubspec.yaml`:

```yaml
dependencies:
  nextgen_showcase: ^0.1.0
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
    return const MaterialApp(home: DemoPage());
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});
  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final GlobalKey _fabKey = GlobalKey();
  final NextgenShowcaseController _controller = NextgenShowcaseController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nextgen Showcase')),
      body: Center(
        child: ElevatedButton(
          key: _fabKey,
          onPressed: () {
            _controller.show(
              context: context,
              targetKey: _fabKey,
              title: 'Primary action',
              description: 'Tap here to perform the main action.',
            );
          },
          child: const Text('Showcase me'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.hide();
        },
        child: const Icon(Icons.close),
      ),
    );
  }
}
```

### Example app
See `example/` for a runnable demo.

### License
MIT
