import 'package:flutter/material.dart';
import 'controller.dart';
import 'models.dart';
import 'config.dart';
import 'theme.dart';

/// A widget that marks a target element for showcasing.
///
/// This widget wraps the UI element that should be highlighted during
/// a showcase step. It acts as a marker for the showcase system to
/// identify and spotlight the target element.
class ShowcaseTarget extends StatelessWidget {
  /// Creates a showcase target widget.
  ///
  /// The [child] parameter is required and represents the widget
  /// that will be highlighted during the showcase.
  const ShowcaseTarget({super.key, required this.child});

  /// The widget to be highlighted during the showcase.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// High-level widget to start a showcase with minimal setup.
///
/// This is the main widget that orchestrates the entire showcase experience.
/// It manages the showcase lifecycle, handles step navigation, and provides
/// the visual overlay with spotlight effects.
///
/// Example usage:
/// ```dart
/// NextgenShowcase(
///   controller: showcaseController,
///   steps: [
///     ShowcaseStep(
///       key: GlobalKey(),
///       title: 'Welcome!',
///       description: 'This is your first step.',
///     ),
///   ],
///   child: YourApp(),
/// )
/// ```
class NextgenShowcase extends StatefulWidget {
  /// Creates a NextgenShowcase widget.
  ///
  /// The [controller], [steps], and [child] parameters are required.
  /// The [config] parameter is optional and allows customization of the
  /// showcase appearance and behavior.
  const NextgenShowcase({
    super.key,
    this.controller,
    required this.steps,
    this.config,
    this.autoStart = true,
    this.initialIndex = 0,
    required this.child,
  });

  /// The controller that manages the showcase state and navigation.
  final NextgenShowcaseController? controller;

  /// The list of showcase steps to be displayed.
  final List<ShowcaseStep> steps;

  /// Optional configuration for customizing the showcase appearance.
  final ShowcaseConfig? config;

  /// Whether the showcase should start automatically when the widget is built.
  ///
  /// Defaults to `true`. When `false`, you need to manually call
  /// [NextgenShowcaseController.start] to begin the showcase.
  final bool autoStart;

  /// The index of the step to start with.
  ///
  /// Defaults to `0` (first step). Must be within the bounds of [steps].
  final int initialIndex;

  /// The child widget that contains the UI elements to be showcased.
  final Widget child;

  @override
  State<NextgenShowcase> createState() => _NextgenShowcaseState();
}

class _NextgenShowcaseState extends State<NextgenShowcase> {
  late final NextgenShowcaseController _controller =
      widget.controller ?? NextgenShowcaseController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.setSteps(_withDefaults(widget.steps));
    _controller.setConfig(widget.config);
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.start(context, initialIndex: widget.initialIndex);
      });
    }
  }

  @override
  void didUpdateWidget(covariant NextgenShowcase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.steps != widget.steps || oldWidget.config != widget.config) {
      _controller.setSteps(_withDefaults(widget.steps));
      _controller.setConfig(widget.config);
      if (_controller.isShowing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.rebuild(context);
        });
      }
    }
  }

  List<ShowcaseStep> _withDefaults(List<ShowcaseStep> steps) {
    final ShowcaseConfig? c = widget.config;
    if (c == null) return steps;
    return steps.map((ShowcaseStep s) {
      return ShowcaseStep(
        key: s.key,
        title: s.title,
        description: s.description,
        shape: (c.defaultShape is ShowcaseShape
            ? c.defaultShape as ShowcaseShape
            : s.shape),
        borderRadius: c.defaultBorderRadius ?? s.borderRadius,
        actions: s.actions,
        padding: c.defaultPadding ?? s.padding,
        contentBuilder: s.contentBuilder,
        customCutoutPath: s.customCutoutPath,
      );
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final NextgenShowcaseThemeData base = NextgenShowcaseTheme.of(context);
    final NextgenShowcaseThemeData data = _mergeTheme(base, widget.config);
    return NextgenShowcaseTheme(
      data: data,
      child: widget.child,
    );
  }

  NextgenShowcaseThemeData _mergeTheme(
      NextgenShowcaseThemeData base, ShowcaseConfig? config) {
    if (config == null) return base;
    return base.copyWith(
      backdropColor: config.backdropColor,
      cardColor: config.cardColor,
      titleStyle: config.titleStyle,
      descriptionStyle: config.descriptionStyle,
      spotlightShadowColor: config.spotlightShadowColor,
      spotlightShadowBlur: config.spotlightShadowBlur,
      stunMode: config.stunMode,
      gradientColors: config.gradientColors,
      gradientAnimationMs: config.gradientAnimationMs,
      glassBlurSigma: config.glassBlurSigma,
      cardOpacity: config.cardOpacity,
      glowPulseDelta: config.glowPulseDelta,
    );
  }
}
