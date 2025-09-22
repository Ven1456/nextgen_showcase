/// A Flutter package for creating guided product tours and spotlight walkthroughs.
///
/// This library provides widgets and utilities for creating interactive showcases
/// that highlight specific UI elements with customizable spotlight effects,
/// glass morphism, and smooth animations.
///
/// The main entry point is the [NextgenShowcase] widget, which wraps your
/// existing UI and provides the showcase functionality.
///
/// ## Advanced Features
///
/// This package now includes comprehensive advanced features:
/// - Multiple highlight shapes (polygon, star, custom paths)
/// - Advanced animations (scale, pulse, glow, bounce, elastic)
/// - Multi-widget highlighting
/// - Rich tooltip content with adaptive positioning
/// - Background effects (gradients, blur, glass morphism)
/// - Accessibility and internationalization support
/// - Gesture navigation and auto-advance
/// - State persistence and restoration
/// - Custom animations and extensibility
library nextgen_showcase;

export 'src/config.dart';
export 'src/controller.dart';
export 'src/advanced_controller.dart';
export 'src/models.dart';
export 'src/nextgen_showcase.dart';
export 'src/theme.dart';
export 'src/builder.dart';
export 'src/showcase_builder.dart';
export 'src/showcase_manager.dart';
export 'src/storage.dart';
export 'src/api.dart';
export 'src/easy_showcase.dart';

// Advanced UI components
export 'src/ui/advanced_spotlight_painter.dart';
export 'src/ui/advanced_background_painter.dart';
export 'src/ui/advanced_tooltip.dart';
export 'src/ui/advanced_showcase_overlay.dart';
