# nextgen_showcase

A modern, lightweight Flutter package to create guided product tours and spotlight walkthroughs in minutes.  
Now with enhanced animations, improved visual effects, and a simplified API!

[![Pub Version](https://img.shields.io/pub/v/nextgen_showcase.svg)](https://pub.dev/packages/nextgen_showcase)
[![Repo]](https://github.com/Ven1456/nextgen_showcase)

---

## ✨ Features
- ✅ **Enhanced Visual Effects** – Gradient backgrounds & glass morphism
- ✅ **Smooth Animations** – Multiple transition types
- ✅ **Multiple Spotlight Shapes** – Rectangle, circle, oval, stadium, diamond, custom
- ✅ **Simplified API** – Fluent `ShowcaseFlowBuilder` with presets
- ✅ **Material 3 Design** – Modern info card styles
- ✅ **Cross-Platform** – Works on mobile, web, and desktop
- ✅ **Accessibility** – Screen reader & keyboard navigation
- ✅ **Flexible Theming** – Presets & custom theme builder

---

## 🚀 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  nextgen_showcase: ^0.1.9
```

Then run:

```bash
flutter pub get
```

### ⚡ Quick Start

#### Simple API (Recommended)
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
  final GlobalKey _fabKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nextgen Showcase')),
      body: Center(
        child: ElevatedButton(
          key: _buttonKey,
          onPressed: () {
            // Using the new simplified API
            ShowcaseFlowBuilder.create()
              .addStep(
                key: _buttonKey,
                title: 'Welcome!',
                description: 'This is a simple showcase demo with enhanced animations.',
              )
              .addCircularStep(
                key: _fabKey,
                title: 'Floating Action Button',
                description: 'This demonstrates circular spotlight shapes.',
              )
              .withConfig(ShowcasePresets.modern())
              .start(context);
          },
          child: const Text('Start Tour'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

#### Traditional API
```dart
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
                shape: ShowcaseShape.circle,
              ),
            ]);
            _controller.setConfig(ShowcasePresets.modern());
            _controller.start(context);
          },
          child: const Text('Showcase me'),
        ),
      ),
    );
  }
}
```

### Advanced Features

#### 🎨 Preset Configurations
```dart
// Modern glass morphism effect
ShowcasePresets.modern()

// Minimal subtle effect
ShowcasePresets.minimal()

// Playful bouncy animations
ShowcasePresets.playful()

// Professional business look
ShowcasePresets.professional()
```

#### 🎬 Transitions
```dart
ShowcaseFlowBuilder.create()
  .addStep(key: _key, title: 'Title', description: 'Description')
  .withTransition(CardTransition.bounceIn, durationMs: 600)
  .start(context);
```

#### Available Transitions
- `CardTransition.fade` - Simple fade in/out
- `CardTransition.zoom` - Scale animation with elastic curve
- `CardTransition.slideUp` - Slide from bottom
- `CardTransition.elasticIn` - Bouncy elastic effect
- `CardTransition.slideFromRight` - Slide from right side
- `CardTransition.bounceIn` - Bouncy scale animation

#### 🎨 Custom Theming
```dart
NextgenShowcaseTheme(
  data: const NextgenShowcaseThemeData(
    backdropColor: Color(0xE6000000),
    gradientColors: [
      Color(0xFF667eea),
      Color(0xFF764ba2),
      Color(0xFFf093fb),
      Color(0xFFf5576c),
    ],
    stunMode: true,
    glassBlurSigma: 15,
  ),
  child: YourApp(),
);
```

#### Extension Methods
```dart
// Create showcase steps easily
final step = _buttonKey.toShowcaseStep(
  title: 'Button',
  description: 'This is a button',
);

// Create circular steps
final circularStep = _fabKey.toCircularShowcaseStep(
  title: 'FAB',
  description: 'This is a floating action button',
);
```
▶️ [Download Demo Video] (https://github.com/Ven1456/nextgen_showcase/blob/1.0.0-improvements/video-reference.mp4)


### What's New in v0.1.9

- 🎨 **Enhanced Visual Effects** - Beautiful gradient backgrounds with improved color schemes
- ⚡ **Smooth Animations** - New transition types and improved timing curves
- 🛠️ **Simplified API** - Fluent builder pattern with `ShowcaseFlowBuilder` class
- 🎯 **Fixed Shape Rendering** - Improved alignment and precision for all spotlight shapes
- 🎪 **Preset Configurations** - Ready-to-use themes for common use cases
- 📱 **Real-world Demo** - Comprehensive e-commerce app example with smooth transitions

### Example app
See `example/` for a comprehensive demo featuring:
- E-commerce app showcase with multiple steps
- Different animation types and transitions
- Preset configuration examples
- Custom content builders
- Shape rendering demonstrations

### 📌 Roadmap
- [ ] Auto-positioning of info card (above/below target)
- [ ] Async step actions (e.g., open links)
- [ ] Gesture-based navigation (swipe to next/previous)
- [ ] Progress indicators for multi-step tours

### 🤝 Contributing
Contributions are welcome! Please open an issue or PR.

### 📄 License
MIT
