# nextgen_showcase

A comprehensive, feature-rich Flutter package for creating advanced guided product tours and spotlight walkthroughs.  
Now with **10 major feature categories** including advanced shapes, animations, multi-widget highlighting, accessibility, and much more!

[![Pub Version](https://img.shields.io/pub/v/nextgen_showcase.svg)](https://pub.dev/packages/nextgen_showcase)
[![View on GitHub](https://img.shields.io/badge/View%20on-GitHub-blue?logo=github)](https://github.com/Ven1456/nextgen_showcase)
---

## 🚀 Advanced Features

### 🎯 1. Shapes & Highlight Cutouts
- ✅ **Basic Shapes**: Rectangle, Circle, RoundedRectangle, Oval, Stadium, Diamond
- ✅ **Advanced Shapes**: Polygon (3-20 sides), Star (configurable points), Custom Paths
- ✅ **Dynamic Sizing**: Adapts to widget size and padding automatically
- ✅ **Multiple Highlights**: Support for highlighting multiple widgets simultaneously
- ✅ **Advanced Animations**: Scale, Pulse, Glow, Bounce, Elastic, Custom animations

### 🎨 2. Background & Blurring
- ✅ **Backdrop Options**: Solid color, Gradient backgrounds, Blur effects, Dimming
- ✅ **Glass Morphism**: Frosted glass look with configurable blur and transparency
- ✅ **Hole Punch Transparency**: Configurable highlight cutout transparency
- ✅ **Theming Support**: Automatic dark/light mode adaptation

### ⚡ 3. Animations & Transitions
- ✅ **Smooth Transitions**: Fade in/out, scaling, pulsing, glowing effects
- ✅ **Advanced Animations**: Slide/fade tooltips, chained animations
- ✅ **Physics-Based**: Spring effects, elastic animations, realistic physics
- ✅ **Custom Animations**: Full support for custom animation controllers

### 💬 4. Tooltip / Info Card
- ✅ **Smart Placement**: Auto, Top, Bottom, Left, Right, Corner positions
- ✅ **Adaptive Positioning**: Automatically repositions near screen edges
- ✅ **Customizable Shapes**: Rounded rectangle, bubble with arrow, custom widgets
- ✅ **Rich Content**: Title + description + icons + images support
- ✅ **Hero Animation**: Tooltip moves with highlight transitions

### 🎮 5. User Interaction Control
- ✅ **Flexible Interaction**: Allow/block tapping on highlighted widgets
- ✅ **Gesture Support**: Swipe navigation, tap anywhere to continue
- ✅ **Configurable Buttons**: Skip/next/done buttons with custom styling
- ✅ **Auto Navigation**: Manual control or auto step navigation

### 🛠️ 6. Developer Experience (DX)
- ✅ **Simple API**: One-liner setup for basic showcase
- ✅ **Global Controller**: Programmatic control with `AdvancedShowcaseController`
- ✅ **Declarative Style**: `ShowcaseStep` widgets wrapping children
- ✅ **Async Flow**: Await completion of showcase steps
- ✅ **State Restoration**: Resume showcase from where user left off

### 🚀 7. Performance & Reliability
- ✅ **Efficient Rendering**: Uses Overlay instead of rebuilding widget tree
- ✅ **Optimized Blur**: Efficient blur effects for large areas
- ✅ **Layout Handling**: Graceful screen rotation and layout changes
- ✅ **Multi-Platform**: Support for different screen densities and aspect ratios

### ♿ 8. Accessibility & Internationalization
- ✅ **Screen Reader Support**: VoiceOver/TalkBack friendly
- ✅ **Keyboard Navigation**: Full keyboard accessibility for web/desktop
- ✅ **RTL Support**: Right-to-left text and layout support
- ✅ **Localization**: Multi-language support with proper cultural adaptation

### 🌟 9. Modern Features
- ✅ **Multi-Widget Highlight**: Highlight multiple widgets simultaneously
- ✅ **Interactive Tooltips**: Buttons, checkboxes inside tooltips
- ✅ **Progress Indicators**: Step X of Y with visual progress bars
- ✅ **Persistent Showcase**: Tooltips pinned until dismissed
- ✅ **Shape Morphing**: Smooth transitions between different highlight shapes

### 🔧 10. Extensibility
- ✅ **Custom Animations**: Plug in your own animation controllers
- ✅ **Event System**: onStart, onNext, onSkip, onFinish callbacks
- ✅ **Flexible Builders**: Custom tooltip and overlay builders
- ✅ **Theme Support**: Global styles configurable once

---

## 🚀 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  nextgen_showcase: ^0.1.10
```

Then run:

```bash
flutter pub get
```

### ⚡ Quick Start

#### Advanced API (Recommended)
```dart
import 'package:flutter/material.dart';
import 'package:nextgen_showcase/nextgen_showcase.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return NextgenShowcaseTheme(
      data: NextgenShowcaseThemeData(
        backgroundType: BackgroundType.glass,
        stunMode: true,
        gradientColors: [Colors.blue, Colors.purple],
      ),
      child: const MaterialApp(home: DemoPage(), debugShowCheckedModeBanner: false),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});
  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> with TickerProviderStateMixin {
  final GlobalKey _buttonKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();
  late AdvancedShowcaseController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdvancedShowcaseController();
    _controller.initializeAnimations(this);
  }

  @override
  void dispose() {
    _controller.disposeAnimations();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Showcase')),
      body: Center(
        child: ElevatedButton(
          key: _buttonKey,
          onPressed: () {
            // Advanced showcase with all features
            _controller.setSteps([
              ShowcaseStep(
                key: _buttonKey,
                title: 'Welcome to Advanced Showcase!',
                description: 'This demonstrates advanced features with star shape and pulse animation.',
                shape: ShowcaseShape.star,
                starPoints: 6,
                starInnerRadius: 0.3,
                highlightAnimation: HighlightAnimation.pulse,
                animationDuration: const Duration(milliseconds: 800),
                tooltipPlacement: TooltipPlacement.auto,
                tooltipShape: TooltipShape.bubble,
                tooltipArrow: true,
                richContent: 'This is **rich content** with *formatting*!',
                icon: Icons.star,
                progressIndicator: true,
                autoAdvance: true,
                autoAdvanceDelay: const Duration(seconds: 3),
                allowTapHighlight: true,
                gestureSupport: true,
              ),
              ShowcaseStep(
                key: _fabKey,
                title: 'Multi-Widget Highlight',
                description: 'This step highlights multiple widgets simultaneously.',
                shape: ShowcaseShape.circle,
                highlightAnimation: HighlightAnimation.elastic,
                onStart: () {
                  _controller.highlightMultiple(context, [_buttonKey, _fabKey]);
                },
              ),
            ]);
            _controller.startAdvanced(context);
          },
          child: const Text('Start Advanced Tour'),
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

## 📚 Advanced Usage Examples

### 🎯 Advanced Shapes & Animations
```dart
// Polygon shape with custom sides
ShowcaseStep(
  key: myKey,
  title: 'Polygon Shape',
  description: '8-sided polygon with glow animation',
  shape: ShowcaseShape.polygon,
  polygonSides: 8,
  highlightAnimation: HighlightAnimation.glow,
  animationDuration: Duration(milliseconds: 1000),
)

// Star shape with custom points
ShowcaseStep(
  key: myKey,
  title: 'Star Shape',
  description: '6-pointed star with pulse animation',
  shape: ShowcaseShape.star,
  starPoints: 6,
  starInnerRadius: 0.4,
  highlightAnimation: HighlightAnimation.pulse,
)

// Custom path with bounce animation
ShowcaseStep(
  key: myKey,
  title: 'Custom Shape',
  description: 'Custom diamond shape with bounce',
  shape: ShowcaseShape.diamond,
  highlightAnimation: HighlightAnimation.bounce,
  customCutoutBuilder: (rect) {
    final path = Path();
    // Create custom diamond path
    path.moveTo(rect.center.dx, rect.top);
    path.lineTo(rect.right, rect.center.dy);
    path.lineTo(rect.center.dx, rect.bottom);
    path.lineTo(rect.left, rect.center.dy);
    path.close();
    return path;
  },
)
```

### 🎨 Advanced Backgrounds & Effects
```dart
NextgenShowcaseTheme(
  data: NextgenShowcaseThemeData(
    // Glass morphism effect
    backgroundType: BackgroundType.glass,
    backdropColor: Colors.black.withAlpa(70),
    backdropBlurSigma: 15.0,
    glassBlurSigma: 20.0,
    
    // Animated gradient
    gradientColors: [
      Color(0xFF667eea),
      Color(0xFF764ba2),
      Color(0xFFf093fb),
      Color(0xFFf5576c),
    ],
    gradientAnimationMs: 3000,
    
    // Advanced theming
    tooltipBackgroundColor: Colors.white,
    tooltipBorderColor: Colors.blue,
    tooltipBorderWidth: 2.0,
    tooltipShadowBlur: 12.0,
    arrowSize: 12.0,
    arrowColor: Colors.blue,
  ),
  child: MyApp(),
)
```

### 💬 Rich Tooltips & Content
```dart
ShowcaseStep(
  key: myKey,
  title: 'Rich Content Tooltip',
  description: 'Basic description',
  richContent: '''
    This is **bold text** and *italic text*!
    
    You can also include:
    - Bullet points
    - Multiple lines
    - Rich formatting
  ''',
  icon: Icons.info,
  image: 'assets/example.png',
  tooltipPlacement: TooltipPlacement.auto,
  tooltipShape: TooltipShape.bubble,
  tooltipArrow: true,
  heroAnimation: true,
)
```

### 🎮 Multi-Widget Highlighting
```dart
// Highlight multiple widgets simultaneously
controller.highlightMultiple(context, [
  button1Key,
  button2Key,
  button3Key,
]);

// Or create a step that highlights multiple widgets
ShowcaseStep(
  key: primaryKey,
  title: 'Multiple Widgets',
  description: 'These widgets work together',
  onStart: () {
    controller.highlightMultiple(context, [
      primaryKey,
      secondaryKey,
      tertiaryKey,
    ]);
  },
)
```

### ♿ Accessibility & Internationalization
```dart
// Enable accessibility features
controller.setAccessibilityEnabled(true);

// RTL support
NextgenShowcaseTheme(
  data: NextgenShowcaseThemeData(
    rtlSupport: true,
    accessibilityAnnouncements: true,
    keyboardNavigation: true,
  ),
  child: MyApp(),
)

// Custom accessibility announcements
controller.announceForAccessibility('Step 1 of 5: Welcome to the app');
```

### 🔧 Custom Animations & Extensibility
```dart
// Custom animation controller
final customAnimation = AnimationController(
  duration: Duration(milliseconds: 1500),
  vsync: this,
);

ShowcaseStep(
  key: myKey,
  title: 'Custom Animation',
  description: 'This uses a custom animation',
  highlightAnimation: HighlightAnimation.custom,
  customAnimation: customAnimation,
  onStart: () {
    customAnimation.forward();
  },
)

// Event callbacks
controller.onStepStart = (index) => print('Step $index started');
controller.onStepComplete = (index) => print('Step $index completed');
controller.onShowcaseEnd = () => print('Showcase completed');
controller.onHighlightChanged = (rect) => print('Highlight changed: $rect');
```

### 🚀 Performance Optimization
```dart
// Efficient blur for large areas
NextgenShowcaseTheme(
  data: NextgenShowcaseThemeData(
    backdropBlurSigma: 8.0, // Moderate blur for performance
    glassBlurSigma: 12.0,   // Efficient glass effect
  ),
  child: MyApp(),
)

// Use RepaintBoundary for complex custom painters
RepaintBoundary(
  child: CustomPaint(
    painter: MyCustomPainter(),
  ),
)
```
▶️ [Download Demo Video] (https://github.com/Ven1456/nextgen_showcase/blob/1.0.0-improvements/video-reference.mp4)


### What's New in v0.2.0 - Advanced Features Release

- 🎯 **Advanced Shapes** - Polygon, Star, Diamond, and Custom Path support with dynamic sizing
- ⚡ **Advanced Animations** - Scale, Pulse, Glow, Bounce, Elastic, and Custom animations
- 🎨 **Background Effects** - Glass morphism, animated gradients, blur effects, and hole punch transparency
- 💬 **Rich Tooltips** - Adaptive positioning, rich content, icons, images, and hero animations
- 🎮 **Multi-Widget Highlighting** - Highlight multiple widgets simultaneously with combined effects
- ♿ **Accessibility & i18n** - Full screen reader support, keyboard navigation, RTL support, and localization
- 🛠️ **Advanced Controller** - `AdvancedShowcaseController` with comprehensive event system
- 🚀 **Performance Optimized** - Efficient rendering, optimized blur effects, and layout handling
- 🌟 **Modern Features** - Interactive tooltips, progress indicators, persistent showcases, and shape morphing
- 🔧 **Extensibility** - Custom animations, flexible builders, and comprehensive theming system

### Example app
See `example/` for a comprehensive demo featuring:
- **Advanced Showcase Example** - Complete demonstration of all 10 feature categories
- **Multi-Widget Highlighting** - Simultaneous highlighting of multiple widgets
- **Advanced Shapes & Animations** - Polygon, star, diamond shapes with custom animations
- **Rich Tooltips** - Adaptive positioning, rich content, icons, and images
- **Accessibility Features** - Screen reader support and keyboard navigation
- **Custom Theming** - Glass morphism, animated gradients, and advanced styling
- **Performance Optimization** - Efficient rendering and smooth animations
- **Real-world Scenarios** - Practical examples for different use cases

### 📌 Roadmap
- [x] ✅ Auto-positioning of info card (above/below target) - **COMPLETED**
- [x] ✅ Async step actions (e.g., open links) - **COMPLETED**
- [x] ✅ Gesture-based navigation (swipe to next/previous) - **COMPLETED**
- [x] ✅ Progress indicators for multi-step tours - **COMPLETED**
- [x] ✅ Advanced shapes (polygon, star, custom paths) - **COMPLETED**
- [x] ✅ Multi-widget highlighting - **COMPLETED**
- [x] ✅ Accessibility & internationalization - **COMPLETED**
- [x] ✅ Advanced animations & transitions - **COMPLETED**
- [x] ✅ Rich tooltip content - **COMPLETED**
- [x] ✅ Performance optimization - **COMPLETED**

### 🚀 Future Enhancements
- [ ] **AI-Powered Positioning** - Smart tooltip placement using ML
- [ ] **Voice Commands** - Voice-controlled showcase navigation
- [ ] **AR Integration** - Augmented reality showcase overlays
- [ ] **Analytics Integration** - Built-in usage analytics and heatmaps
- [ ] **Template Gallery** - Pre-built showcase templates for common scenarios

### 🤝 Contributing
Contributions are welcome! Please open an issue or PR.

### 📄 License
MIT
