import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'models.dart';
import 'theme.dart';
import 'config.dart';

/// Controller for managing showcase state and navigation.
///
/// This controller provides methods to start, stop, and navigate through
/// showcase steps. It manages the overlay display and handles user interactions.
///
/// Example usage:
/// ```dart
/// final controller = NextgenShowcaseController();
/// 
/// // Start the showcase
/// controller.start(context);
/// 
/// // Navigate to next step
/// controller.next(context);
/// 
/// // Dismiss the showcase
/// controller.dismiss();
/// ```
class NextgenShowcaseController {
  /// Creates a showcase controller.
  ///
  /// The [config] parameter is optional and allows setting default
  /// configuration that can be overridden later.
  NextgenShowcaseController({ShowcaseConfig? config}) : _config = config;

  OverlayEntry? _activeEntry;
  final List<ShowcaseStep> _steps = <ShowcaseStep>[];
  int _currentIndex = -1;
  final ShowcaseConfig? _config;

  /// Whether the showcase is currently being displayed.
  bool get isShowing => _activeEntry != null;
  
  /// Whether there are any steps available for showcasing.
  bool get hasSteps => _steps.isNotEmpty;
  
  /// The current step index (0-based).
  ///
  /// Returns -1 if no showcase is active.
  int get currentIndex => _currentIndex;
  
  /// The current showcase step being displayed.
  ///
  /// Returns `null` if no showcase is active or if the current index
  /// is out of bounds.
  ShowcaseStep? get currentStep => (_currentIndex >= 0 && _currentIndex < _steps.length) ? _steps[_currentIndex] : null;

  /// Sets the list of showcase steps.
  ///
  /// This replaces any existing steps with the new list.
  /// Call this method when you need to update the showcase steps.
  void setSteps(List<ShowcaseStep> steps) {
    _steps
      ..clear()
      ..addAll(steps);
  }

  /// Update configuration while running.
  void setConfig(ShowcaseConfig? config) {
    // ignore: invalid_use_of_visible_for_testing_member
    // ignore reason: simple state holder, safe to update
    // (We keep a private field; just reassign and trigger rebuild when asked.)
    // This method does not trigger rebuild by itself to avoid requiring a context here.
    // Call [rebuild] from a widget with context after updating.
    //
    // Use a local variable to avoid shadowing analyzer warnings.
    final ShowcaseConfig? newConfig = config;
    (this as dynamic)._config = newConfig;
  }

  /// Request rebuild of the overlay if visible.
  void rebuild(BuildContext context) => _rebuild(context);

  /// Starts the showcase with the specified initial step.
  ///
  /// The [context] parameter is required for overlay management.
  /// The [initialIndex] parameter specifies which step to start with
  /// (defaults to 0 for the first step).
  ///
  /// If there are no steps available, this method does nothing.
  void start(BuildContext context, {int initialIndex = 0}) {
    if (_steps.isEmpty) {
      return;
    }
    _currentIndex = initialIndex.clamp(0, _steps.length - 1);
    _showCurrent(context);
  }

  /// Advances to the next step in the showcase.
  ///
  /// If this is the last step, the showcase will be dismissed.
  /// If no showcase is active, this method does nothing.
  void next(BuildContext context) {
    if (_currentIndex < 0) return;
    if (_currentIndex + 1 >= _steps.length) {
      dismiss();
    } else {
      _currentIndex += 1;
      _rebuild(context);
    }
  }

  /// Goes back to the previous step in the showcase.
  ///
  /// If this is the first step or no showcase is active, this method does nothing.
  void previous(BuildContext context) {
    if (_currentIndex <= 0) return;
    _currentIndex -= 1;
    _rebuild(context);
  }

  /// Dismisses the current showcase.
  ///
  /// This removes the overlay and resets the controller state.
  void dismiss() {
    _activeEntry?.remove();
    _activeEntry = null;
    _currentIndex = -1;
  }

  void _rebuild(BuildContext context) {
    _activeEntry?.markNeedsBuild();
  }

  void _showCurrent(BuildContext context) {
    final ShowcaseStep step = _steps[_currentIndex];
    final RenderBox? targetRenderBox =
        step.key.currentContext?.findRenderObject() as RenderBox?;
    if (targetRenderBox == null) {
      return;
    }

    final Offset targetOffset = targetRenderBox.localToGlobal(Offset.zero);
    final Size targetSize = targetRenderBox.size;

    _activeEntry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        final NextgenShowcaseThemeData baseTheme = NextgenShowcaseTheme.of(context);
        final NextgenShowcaseThemeData mergedTheme = _mergeTheme(baseTheme, _config);
        return NextgenShowcaseTheme(
          data: mergedTheme,
          child: _ShowcaseOverlay(
            controller: this,
            targetOffset: targetOffset,
            targetSize: targetSize,
            onClose: dismiss,
            onNext: () => next(context),
            onPrevious: () => previous(context),
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_activeEntry!);
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

class _ShowcaseOverlay extends StatefulWidget {
  const _ShowcaseOverlay({
    required this.controller,
    required this.targetOffset,
    required this.targetSize,
    required this.onClose,
    required this.onNext,
    required this.onPrevious,
  });

  final NextgenShowcaseController controller;
  final Offset targetOffset;
  final Size targetSize;
  final VoidCallback onClose;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  State<_ShowcaseOverlay> createState() => _ShowcaseOverlayState();
}

class _ShowcaseOverlayState extends State<_ShowcaseOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int ms = NextgenShowcaseTheme.of(context).gradientAnimationMs;
    _anim.duration = Duration(milliseconds: ms);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NextgenShowcaseThemeData showcaseTheme = NextgenShowcaseTheme.of(context);
    final ShowcaseStep? step = widget.controller.currentStep;
    final Size screenSize = MediaQuery.of(context).size;

    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: widget.onClose,
          onHorizontalDragEnd: (DragEndDetails d) {
            if (d.primaryVelocity == null) return;
            if (d.primaryVelocity! < 0) {
              widget.onNext();
            } else if (d.primaryVelocity! > 0) {
              widget.onPrevious();
            }
          },
          child: const SizedBox.expand(),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (BuildContext context, Widget? child) {
              if (step == null) return const SizedBox.shrink();
              return CustomPaint(
                painter: _SpotlightPainter(
                  rect: Rect.fromLTWH(widget.targetOffset.dx, widget.targetOffset.dy, widget.targetSize.width, widget.targetSize.height),
                  shape: step.shape,
                  borderRadius: step.borderRadius,
                  padding: step.padding,
                  shadowColor: showcaseTheme.spotlightShadowColor,
                  shadowBlur: showcaseTheme.spotlightShadowBlur + (showcaseTheme.stunMode ? (showcaseTheme.glowPulseDelta * _pulse.value) : 0),
                  customCutoutPath: step.customCutoutPath,
                  stunMode: showcaseTheme.stunMode,
                  backdropColor: showcaseTheme.backdropColor,
                  gradientColors: showcaseTheme.gradientColors,
                  gradientT: _pulse.value,
                ),
              );
            },
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: (widget.targetOffset.dy + widget.targetSize.height + 16)
              .clamp(16.0, screenSize.height - 200),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            builder: (BuildContext context, double t, Widget? child) {
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: t.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, (1 - t) * 16),
                  child: Transform.scale(
                    scale: t,
                    alignment: Alignment.topCenter,
                    child: child,
                  ),
                ),
              );
            },
            child: (step?.contentBuilder) != null
                ? _GlassWrap(child: Builder(builder: step!.contentBuilder!))
                : _GlassCard(
                    title: step?.title ?? '',
                    description: step?.description ?? '',
                    actions: step?.actions ?? const <ShowcaseAction>[],
                    onClose: widget.onClose,
                    onNext: widget.onNext,
                    onPrevious: widget.onPrevious,
                  ),
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.title,
    required this.description,
    required this.actions,
    required this.onClose,
    required this.onNext,
    required this.onPrevious,
  });

  final String title;
  final String description;
  final List<ShowcaseAction> actions;
  final VoidCallback onClose;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NextgenShowcaseThemeData t = NextgenShowcaseTheme.of(context);
    final bool glass = t.stunMode;
    final Color baseColor = (t.cardColor) ?? theme.colorScheme.surface;
    final Color cardColor = glass ? baseColor.withAlpha(t.cardOpacity.toInt()) : baseColor;
    final BorderRadius radius = BorderRadius.circular(16);

    Widget content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: glass ? Border.all(color: Colors.white.withAlpha(20)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: t.titleStyle ?? theme.textTheme.titleLarge,
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: onClose),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: t.descriptionStyle ?? theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              TextButton(onPressed: onPrevious, child: const Text('Previous')),
              const Spacer(),
              ...actions.map((ShowcaseAction action) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilledButton.tonal(
                    onPressed: action.onPressed,
                    child: Text(action.label),
                  ),
                );
              }),
              const SizedBox(width: 8),
              FilledButton(onPressed: onNext, child: const Text('Next')),
            ],
          ),
        ],
      ),
    );

    if (!glass) return Material(color: Colors.transparent, child: content);

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: t.glassBlurSigma, sigmaY: t.glassBlurSigma),
          child: content,
        ),
      ),
    );
  }
}

class _GlassWrap extends StatelessWidget {
  const _GlassWrap({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NextgenShowcaseThemeData t = NextgenShowcaseTheme.of(context);
    final ThemeData theme = Theme.of(context);
    final BorderRadius radius = BorderRadius.circular(16);
    final Color baseColor = (t.cardColor) ?? theme.colorScheme.surface;
    final Color cardColor = t.stunMode ? baseColor.withAlpha(t.cardOpacity.toInt()) : baseColor;
    Widget content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withAlpha(t.cardOpacity.toInt()),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: t.stunMode ? Border.all(color: Colors.white.withAlpha(20)) : null,
      ),
      child: child,
    );
    if (!t.stunMode) return Material(color: Colors.transparent, child: content);
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: t.glassBlurSigma, sigmaY: t.glassBlurSigma),
          child: content,
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.rect,
    required this.shape,
    required this.borderRadius,
    required this.padding,
    required this.shadowColor,
    required this.shadowBlur,
    this.customCutoutPath,
    this.stunMode = false,
    this.backdropColor = const Color(0xCC000000),
    this.gradientColors = const <Color>[Colors.black],
    this.gradientT = 0,
  });

  final Rect rect;
  final ShowcaseShape shape;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Color shadowColor;
  final double shadowBlur;
  final Path? customCutoutPath;
  final bool stunMode;
  final Color backdropColor;
  final List<Color> gradientColors;
  final double gradientT;

  @override
  void paint(Canvas canvas, Size size) {
    final Path backdrop = Path()..addRect(Offset.zero & size);
    final Path cutout = Path()..fillType = PathFillType.evenOdd;

    // Apply configurable padding around the rect for spotlight breathing room
    final Rect padded = Rect.fromLTWH(
      rect.left - padding.left,
      rect.top - padding.top,
      rect.width + padding.horizontal,
      rect.height + padding.vertical,
    );

    // Build a dedicated shape path for accurate shadows and cutout
    final Path shapePath = Path();
    switch (shape) {
      case ShowcaseShape.rectangle:
        shapePath.addRect(padded);
        break;
      case ShowcaseShape.circle:
        shapePath.addOval(Rect.fromCircle(center: padded.center, radius: padded.longestSide / 2));
        break;
      case ShowcaseShape.roundedRectangle:
        shapePath.addRRect(RRect.fromRectAndCorners(
          padded,
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
          bottomLeft: borderRadius.bottomLeft,
          bottomRight: borderRadius.bottomRight,
        ));
        break;
      case ShowcaseShape.oval:
        shapePath.addOval(padded);
        break;
      case ShowcaseShape.stadium:
        shapePath.addRRect(RRect.fromRectAndRadius(padded, Radius.circular(padded.shortestSide / 2)));
        break;
      case ShowcaseShape.diamond:
        final Path diamond = Path()
          ..moveTo(padded.center.dx, padded.top)
          ..lineTo(padded.right, padded.center.dy)
          ..lineTo(padded.center.dx, padded.bottom)
          ..lineTo(padded.left, padded.center.dy)
          ..close();
        shapePath.addPath(diamond, Offset.zero);
        break;
      case ShowcaseShape.custom:
        if (customCutoutPath != null) {
          shapePath.addPath(customCutoutPath!, Offset.zero);
        } else {
          shapePath.addRect(padded);
        }
        break;
    }

    // Use even-odd fill to subtract the shape from the backdrop
    cutout
      ..addPath(backdrop, Offset.zero)
      ..addPath(shapePath, Offset.zero);

    final Paint dimPaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.dstOut;

    // Draw either animated gradient + overlay, or solid backdrop
    if (stunMode && gradientColors.length >= 2) {
      final Rect full = Offset.zero & size;
      final Alignment begin = Alignment(-1 + gradientT * 2, -1);
      final Alignment end = Alignment(1 - gradientT * 2, 1);
      final Paint gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: begin,
          end: end,
          colors: gradientColors,
          stops: const <double>[0.0, 0.5, 1.0],
        ).createShader(full);
      canvas.drawRect(full, gradientPaint);
      canvas.drawRect(full, Paint()..color = backdropColor);
    } else {
      canvas.drawRect(Offset.zero & size, Paint()..color = backdropColor);
    }

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawPath(backdrop, Paint()..color = Colors.transparent);
    canvas.drawPath(cutout, dimPaint);
    canvas.restore();

    // Draw glow/shadow precisely around the shape path
    canvas.drawShadow(shapePath, shadowColor, shadowBlur, false);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return rect != oldDelegate.rect ||
        shape != oldDelegate.shape ||
        borderRadius != oldDelegate.borderRadius ||
        padding != oldDelegate.padding ||
        shadowColor != oldDelegate.shadowColor ||
        shadowBlur != oldDelegate.shadowBlur;
  }
}


