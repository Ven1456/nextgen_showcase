import 'package:flutter/material.dart';
import 'controller.dart';
import 'models.dart';
import 'config.dart';
import 'theme.dart';

class ShowcaseTarget extends StatelessWidget {
  const ShowcaseTarget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// High-level widget to start a showcase with minimal setup.
class NextgenShowcase extends StatefulWidget {
  const NextgenShowcase({
    super.key,
    required this.controller,
    required this.steps,
    this.config,
    this.autoStart = true,
    this.initialIndex = 0,
    required this.child,
  });

  final NextgenShowcaseController controller;
  final List<ShowcaseStep> steps;
  final ShowcaseConfig? config;
  final bool autoStart;
  final int initialIndex;
  final Widget child;

  @override
  State<NextgenShowcase> createState() => _NextgenShowcaseState();
}

class _NextgenShowcaseState extends State<NextgenShowcase> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller.setSteps(_withDefaults(widget.steps));
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.start(context, initialIndex: widget.initialIndex);
      });
    }
  }

  @override
  void didUpdateWidget(covariant NextgenShowcase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.steps != widget.steps || oldWidget.config != widget.config) {
      widget.controller.setSteps(_withDefaults(widget.steps));
      widget.controller.setConfig(widget.config);
      if (widget.controller.isShowing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.controller.rebuild(context);
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
        shape: (c.defaultShape is ShowcaseShape ? c.defaultShape as ShowcaseShape : s.shape),
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

  NextgenShowcaseThemeData _mergeTheme(NextgenShowcaseThemeData base, ShowcaseConfig? config) {
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


