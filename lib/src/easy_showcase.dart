import 'package:flutter/material.dart';
import 'advanced_controller.dart';
import 'models.dart';
import 'theme.dart';
import 'config.dart';

/// A simple, tutorial_coach_mark-style facade for showing a guided tour.
///
/// Usage:
///
/// ```dart
/// await EasyShowcase.show(
///   context,
///   targets: [
///     EasyTarget(key: buttonKey, title: 'Title', description: 'Desc'),
///     EasyTarget(key: cardKey, title: 'Next', description: '...'),
///   ],
/// );
/// ```
class EasyShowcase {
  static Future<void> show(
    BuildContext context, {
    required List<EasyTarget> targets,
    NextgenShowcaseThemeData? theme,
    ShowcaseConfig? config,
  }) async {
    if (targets.isEmpty) return;

    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) {
          return _EasyShowcaseHost(
            targets: targets,
            theme: theme,
            config: config,
          );
        },
      ),
    );
  }

  /// Simplest API: pass keys and optional title/description builders.
  /// If not provided, titles/descriptions are auto-generated.
  static Future<void> quick(
    BuildContext context, {
    required List<GlobalKey> keys,
    String Function(int index)? titleFor,
    String Function(int index)? descriptionFor,
    NextgenShowcaseThemeData? theme,
    ShowcaseConfig? config,
  }) async {
    final List<EasyTarget> targets = <EasyTarget>[];
    for (int i = 0; i < keys.length; i += 1) {
      targets.add(EasyTarget(
        key: keys[i],
        title: titleFor != null ? titleFor(i) : 'Step ${i + 1}',
        description: descriptionFor != null
            ? descriptionFor(i)
            : 'Follow the steps to learn the UI.',
      ));
    }
    // Apply a pleasant default theme if none provided
    final NextgenShowcaseThemeData resolvedTheme = theme ?? _defaultTheme();
    return show(
      context,
      targets: targets,
      theme: resolvedTheme,
      config: config,
    );
  }

  /// Ultra-simple helper: just keys.
  static Future<void> showSimple(
    BuildContext context,
    List<GlobalKey> keys,
  ) async {
    return quick(context, keys: keys);
  }

  static NextgenShowcaseThemeData _defaultTheme() {
    return NextgenShowcaseThemeData(
      backgroundType: BackgroundType.glass,
      backdropColor: Colors.black.withAlpha(55),
      backdropBlurSigma: 10,
      gradientColors: const <Color>[
        Color(0xFF6A85B6),
        Color(0xFFBAC8E0),
      ],
      gradientAnimationMs: 3000,
      glassBlurSigma: 16,
      cardOpacity: 0.96,
      glowPulseDelta: 18,
      animationCurve: Curves.easeOutBack,
      animationDuration: const Duration(milliseconds: 450),
      tooltipBackgroundColor: Colors.white,
      tooltipBorderRadius: const BorderRadius.all(Radius.circular(14)),
      tooltipShadowColor: Colors.black.withAlpha(25),
      tooltipShadowBlur: 18,
      tooltipShadowOffset: const Offset(0, 6),
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      tooltipMargin: const EdgeInsets.all(12),
      arrowSize: 12,
      arrowColor: Colors.white,
      progressIndicatorColor: const Color(0xFF6A85B6),
      progressIndicatorBackgroundColor: Colors.black12,
      progressIndicatorHeight: 4,
    );
  }
}

/// Simple target definition for the easy API.
class EasyTarget {
  EasyTarget({
    required this.key,
    required this.title,
    required this.description,
    this.shape = ShowcaseShape.roundedRectangle,
    this.tooltipPlacement = TooltipPlacement.auto,
  });

  final GlobalKey key;
  final String title;
  final String description;
  final ShowcaseShape shape;
  final TooltipPlacement tooltipPlacement;

  /// Convenience factory: title only, description auto.
  factory EasyTarget.titleOnly({
    required GlobalKey key,
    required String title,
  }) {
    return EasyTarget(
      key: key,
      title: title,
      description: 'Follow the steps to learn the UI.',
    );
  }
}

class _EasyShowcaseHost extends StatefulWidget {
  const _EasyShowcaseHost({
    required this.targets,
    this.theme,
    this.config,
  });

  final List<EasyTarget> targets;
  final NextgenShowcaseThemeData? theme;
  final ShowcaseConfig? config;

  @override
  State<_EasyShowcaseHost> createState() => _EasyShowcaseHostState();
}

class _EasyShowcaseHostState extends State<_EasyShowcaseHost>
    with TickerProviderStateMixin {
  late final AdvancedShowcaseController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdvancedShowcaseController(config: widget.config);
    _controller.initializeAnimations(this);

    // Build steps from easy targets with attractive defaults
    final List<ShowcaseStep> steps = widget.targets
        .map((t) => ShowcaseStep(
              key: t.key,
              title: t.title,
              description: t.description,
              shape: t.shape,
              tooltipPlacement: t.tooltipPlacement,
              tooltipShape: TooltipShape.bubble,
              tooltipArrow: true,
              highlightAnimation: HighlightAnimation.pulse,
              animationDuration: const Duration(milliseconds: 500),
              allowTapHighlight: true,
              allowTapOutside: true,
              gestureSupport: true,
            ))
        .toList(growable: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Apply theme if provided
      if (widget.theme != null) {
        final inherited = NextgenShowcaseTheme.of(context);
        final merged = inherited.copyWith(
          backdropColor: widget.theme!.backdropColor,
          backdropBlurSigma: widget.theme!.backdropBlurSigma,
          gradientColors: widget.theme!.gradientColors,
          gradientStops: widget.theme!.gradientStops,
          gradientBegin: widget.theme!.gradientBegin,
          gradientEnd: widget.theme!.gradientEnd,
          dimOpacity: widget.theme!.dimOpacity,
          glassBlurSigma: widget.theme!.glassBlurSigma,
          cardOpacity: widget.theme!.cardOpacity,
          animationCurve: widget.theme!.animationCurve,
          animationDuration: widget.theme!.animationDuration,
          tooltipBackgroundColor: widget.theme!.tooltipBackgroundColor,
          tooltipBorderColor: widget.theme!.tooltipBorderColor,
          tooltipBorderWidth: widget.theme!.tooltipBorderWidth,
          tooltipBorderRadius: widget.theme!.tooltipBorderRadius,
          tooltipShadowColor: widget.theme!.tooltipShadowColor,
          tooltipShadowBlur: widget.theme!.tooltipShadowBlur,
          tooltipShadowOffset: widget.theme!.tooltipShadowOffset,
          tooltipPadding: widget.theme!.tooltipPadding,
          tooltipMargin: widget.theme!.tooltipMargin,
          arrowSize: widget.theme!.arrowSize,
          arrowColor: widget.theme!.arrowColor,
          progressIndicatorColor: widget.theme!.progressIndicatorColor,
          progressIndicatorBackgroundColor:
              widget.theme!.progressIndicatorBackgroundColor,
          progressIndicatorHeight: widget.theme!.progressIndicatorHeight,
        );
        final entry = OverlayEntry(
          builder: (_) => NextgenShowcaseTheme(
            data: merged,
            child: const SizedBox.shrink(),
          ),
        );

        Navigator.of(context).overlay!.insert(entry);
        entry.remove();

      }

      _controller.setSteps(steps);
      _controller.startAdvanced(context);
      _controller.onShowcaseEnd = () {
        if (mounted) Navigator.of(context).maybePop();
      };
    });
  }

  @override
  void dispose() {
    _controller.disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Host is transparent; the controller creates an overlay entry.
    return const SizedBox.shrink();
  }
}


