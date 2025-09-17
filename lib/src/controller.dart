import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'models.dart';
import 'theme.dart';
import 'config.dart';
import 'storage.dart';
import 'ui/spotlight_painter.dart';

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
  ShowcaseConfig? _config;
  ShowcaseStorage? _storage;

  // Lifecycle callbacks
  ValueChanged<int>? onStepStart;
  ValueChanged<int>? onStepComplete;
  VoidCallback? onShowcaseEnd;

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
  ShowcaseStep? get currentStep =>
      (_currentIndex >= 0 && _currentIndex < _steps.length)
          ? _steps[_currentIndex]
          : null;

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
    _config = config;
    if ((config?.persistenceKey != null) &&
        (config?.enablePersistence ?? true)) {
      _storage ??= SharedPrefsShowcaseStorage();
    }
  }

  /// Request rebuild of the overlay if visible.
  void rebuild(BuildContext context) => _rebuild(context);

  /// Convenience: Show a one-off showcase for a single target.
  ///
  /// This API mirrors what tests expect: provide a [context], a [targetKey],
  /// [title] and [description]. It creates a single [ShowcaseStep], sets it,
  /// and starts the showcase immediately.
  void show({
    required BuildContext context,
    required GlobalKey targetKey,
    required String title,
    required String description,
  }) {
    setSteps(<ShowcaseStep>[
      ShowcaseStep(
        key: targetKey,
        title: title,
        description: description,
      ),
    ]);
    start(context);
  }

  /// Convenience: Hide the current showcase if visible.
  void hide() => dismiss();

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
    // Ensure any existing overlay from this controller is removed
    if (_activeEntry != null) {
      _activeEntry!.remove();
      _activeEntry = null;
    }
    _currentIndex = initialIndex.clamp(0, _steps.length - 1);
    // If persisted as completed, skip entirely
    _maybeSkipShowcase().then((bool skip) {
      if (skip) {
        return;
      }
      _showCurrent(context);
    });
  }

  /// Advances to the next step in the showcase.
  ///
  /// If this is the last step, the showcase will be dismissed.
  /// If no showcase is active, this method does nothing.
  void next(BuildContext context) {
    if (_currentIndex < 0) return;
    if (_currentIndex + 1 >= _steps.length) {
      onStepComplete?.call(_currentIndex);
      dismiss();
    } else {
      onStepComplete?.call(_currentIndex);
      _currentIndex += 1;
      _showCurrent(context);
    }
  }

  /// Goes back to the previous step in the showcase.
  ///
  /// If this is the first step or no showcase is active, this method does nothing.
  void previous(BuildContext context) {
    if (_currentIndex <= 0) return;
    _currentIndex -= 1;
    _showCurrent(context);
  }

  /// Dismisses the current showcase.
  ///
  /// This removes the overlay and resets the controller state.
  void dismiss() {
    _activeEntry?.remove();
    _activeEntry = null;
    _currentIndex = -1;
    onShowcaseEnd?.call();
    _markCompleted();
  }

  void _rebuild(BuildContext context) {
    _activeEntry?.markNeedsBuild();
  }

  void _showCurrent(BuildContext context) {
    final ShowcaseStep step = _steps[_currentIndex];

    // Ensure the target is visible in a scrollable before measuring
    final BuildContext? targetContext = step.key.currentContext;
    if (targetContext != null) {
      final ScrollableState? scrollable = Scrollable.maybeOf(targetContext);
      if (scrollable != null) {
        // Try to bring into view; then schedule measurement next frame
        Scrollable.ensureVisible(
          targetContext,
          alignment: 0.5,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    }

    final RenderBox? targetRenderBox =
        targetContext?.findRenderObject() as RenderBox?;
    if (targetRenderBox == null) {
      // Configurable async wait and retry strategy
      final int waitMs = _config?.waitForAsyncMs ?? 150;
      final int maxRetries = _config?.retryMissingTargetMax ?? 5;
      int tries = 0;
      void attempt() {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final RenderBox? retryBox =
              step.key.currentContext?.findRenderObject() as RenderBox?;
          if (retryBox == null) {
            tries += 1;
            if (tries < maxRetries) {
              await Future<void>.delayed(Duration(milliseconds: waitMs));
              attempt();
            } else {
              // ignore: avoid_print
              print(
                  '[nextgen_showcase] Target not found for step ${_currentIndex}. Skipping.');
              if (_currentIndex + 1 < _steps.length) {
                onStepComplete?.call(_currentIndex);
                _currentIndex += 1;
                _showCurrent(context);
              } else {
                dismiss();
              }
            }
          } else {
            _rebuild(context);
          }
        });
      }

      attempt();
      return;
    }

    final Offset targetOffset = targetRenderBox.localToGlobal(Offset.zero);
    final Size targetSize = targetRenderBox.size;

    // Remove any previously inserted overlay before creating a new one
    if (_activeEntry != null) {
      _activeEntry!.remove();
      _activeEntry = null;
    }

    _activeEntry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        final NextgenShowcaseThemeData baseTheme =
            NextgenShowcaseTheme.of(context);
        final NextgenShowcaseThemeData mergedTheme =
            _mergeTheme(baseTheme, _config);
        return NextgenShowcaseTheme(
          data: mergedTheme,
          child: RepaintBoundary(
              child: _ShowcaseOverlay(
            controller: this,
            targetOffset: targetOffset,
            targetSize: targetSize,
            onClose: dismiss,
            onNext: () => next(context),
            onPrevious: () => previous(context),
          )),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_activeEntry!);
    onStepStart?.call(_currentIndex);
  }

  Future<bool> _maybeSkipShowcase() async {
    final ShowcaseConfig? cfg = _config;
    if (cfg == null) return false;
    if (cfg.persistenceKey == null) return false;
    if (!(cfg.enablePersistence ?? true)) return false;
    final bool? seen = await (_storage ?? SharedPrefsShowcaseStorage())
        .readBool('${cfg.persistenceKey!}__completed');
    return seen == true;
  }

  Future<void> _markCompleted() async {
    final ShowcaseConfig? cfg = _config;
    if (cfg == null) return;
    if (cfg.persistenceKey == null) return;
    if (!(cfg.enablePersistence ?? true)) return;
    await (_storage ?? SharedPrefsShowcaseStorage())
        .writeBool('${cfg.persistenceKey!}__completed', true);
  }

  NextgenShowcaseThemeData _mergeTheme(
      NextgenShowcaseThemeData base, ShowcaseConfig? config) {
    if (config == null) return base;
    return base.copyWith(
      backdropColor: config.backdropColor,
      backdropBlurSigma: config.backdropBlurSigma,
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
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
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
    final NextgenShowcaseThemeData showcaseTheme =
        NextgenShowcaseTheme.resolved(context);
    final ShowcaseStep? step = widget.controller.currentStep;
    final Size screenSize = MediaQuery.of(context).size;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowRight): widget.onNext,
        const SingleActivator(LogicalKeyboardKey.arrowLeft): widget.onPrevious,
        const SingleActivator(LogicalKeyboardKey.escape): widget.onClose,
      },
      child: Focus(
        autofocus: true,
        child: Stack(
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
              child: Semantics(
                label: step?.title,
                hint: step?.description,
                liveRegion: true,
                child: const SizedBox.expand(),
              ),
            ),
            if (step != null)
              Positioned.fill(
                child: _BackdropLayer(
                  rect: Rect.fromLTWH(
                    widget.targetOffset.dx,
                    widget.targetOffset.dy,
                    widget.targetSize.width,
                    widget.targetSize.height,
                  ),
                  padding: step.padding,
                  borderRadius: step.borderRadius,
                  customCutoutPath: step.customCutoutPath,
                  customCutoutBuilder: step.customCutoutBuilder,
                  backdropBuilder: widget.controller._config?.backdropBuilder,
                ),
              ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (BuildContext context, Widget? child) {
                  if (step == null) return const SizedBox.shrink();
                  final Rect spotlightRect = Rect.fromLTWH(
                    widget.targetOffset.dx,
                    widget.targetOffset.dy,
                    widget.targetSize.width,
                    widget.targetSize.height,
                  );
                  Widget painted = RepaintBoundary(
                      child: CustomPaint(
                    painter: SpotlightPainter(
                      rect: spotlightRect,
                      borderRadius: step.borderRadius,
                      padding: step.padding,
                      customCutoutPath: step.customCutoutPath,
                      customCutoutBuilder: step.customCutoutBuilder,
                      stunMode: showcaseTheme.stunMode,
                      backdropColor: showcaseTheme.backdropColor,
                      gradientColors: showcaseTheme.gradientColors,
                      gradientT: _pulse.value,
                    ),
                  ));

                  // Inject overlay widgets below card
                  final List<Widget> extra =
                      (widget.controller._config?.overlayWidgetsBuilder)
                              ?.call(context, step, spotlightRect) ??
                          const <Widget>[];

                  Widget stack = Stack(children: <Widget>[painted, ...extra]);

                  // Apply decorators
                  final List<ShowcaseDecorator>? decos =
                      widget.controller._config?.decorators;
                  for (final ShowcaseDecorator d
                      in decos ?? const <ShowcaseDecorator>[]) {
                    stack = d(context, step, spotlightRect, stack);
                  }

                  return stack;
                },
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: (widget.targetOffset.dy + widget.targetSize.height + 16)
                  .clamp(16.0, screenSize.height - 200),
              child: _CardTransitionWrapper(
                transition: widget.controller._config?.cardTransition ??
                    CardTransition.zoom,
                durationMs:
                    widget.controller._config?.cardTransitionDurationMs ?? 320,
                child: (step?.contentBuilder) != null
                    ? RepaintBoundary(
                        child: _GlassWrap(
                            child: Builder(builder: step!.contentBuilder!)))
                    : RepaintBoundary(
                        child: Semantics(
                        container: true,
                        label: step?.title,
                        hint: step?.description,
                        child: _GlassCard(
                          title: step?.title ?? '',
                          description: step?.description ?? '',
                          actions: step?.actions ?? const <ShowcaseAction>[],
                          onClose: widget.onClose,
                          onNext: widget.onNext,
                          onPrevious: widget.onPrevious,
                          testId: step?.testId,
                          controller: widget.controller,
                        ),
                      )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTransitionWrapper extends StatelessWidget {
  const _CardTransitionWrapper({
    required this.child,
    required this.transition,
    required this.durationMs,
  });

  final Widget child;
  final CardTransition transition;
  final int durationMs;

  @override
  Widget build(BuildContext context) {
    final Duration d = Duration(milliseconds: durationMs);
    switch (transition) {
      case CardTransition.fade:
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: d,
          builder: (BuildContext context, double t, Widget? _) {
            return Opacity(opacity: t, child: child);
          },
        );
      case CardTransition.zoom:
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.8, end: 1.0),
          duration: d,
          curve: Curves.elasticOut,
          builder: (BuildContext context, double t, Widget? _) {
            final double alpha = ((t - 0.8) / 0.2).clamp(0.0, 1.0);
            return Opacity(
              opacity: alpha,
              child: Transform.scale(
                  scale: t, alignment: Alignment.topCenter, child: child),
            );
          },
        );
      case CardTransition.slideUp:
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 32, end: 0),
          duration: d,
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double dy, Widget? _) {
            final double alpha = (1 - (dy / 32)).clamp(0.0, 1.0);
            return Opacity(
              opacity: alpha,
              child: Transform.translate(offset: Offset(0, dy), child: child),
            );
          },
        );
      case CardTransition.elasticIn:
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.8, end: 1.0),
          duration: d,
          curve: Curves.elasticOut,
          builder: (BuildContext context, double t, Widget? _) {
            final double alpha = ((t - 0.8) / 0.2).clamp(0.0, 1.0);
            return Opacity(
              opacity: alpha,
              child: Transform.scale(
                  scale: t, alignment: Alignment.topCenter, child: child),
            );
          },
        );
      case CardTransition.slideFromRight:
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 100, end: 0),
          duration: d,
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double dx, Widget? _) {
            final double alpha = (1 - (dx / 100)).clamp(0.0, 1.0);
            return Opacity(
              opacity: alpha,
              child: Transform.translate(offset: Offset(dx, 0), child: child),
            );
          },
        );
      case CardTransition.bounceIn:
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.3, end: 1.0),
          duration: d,
          curve: Curves.bounceOut,
          builder: (BuildContext context, double t, Widget? _) {
            final double alpha = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
            return Opacity(
              opacity: alpha,
              child: Transform.scale(
                  scale: t, alignment: Alignment.center, child: child),
            );
          },
        );
    }
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
    required this.controller,
    this.testId,
  });

  final String title;
  final String description;
  final List<ShowcaseAction> actions;
  final VoidCallback onClose;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final String? testId;
  final NextgenShowcaseController? controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NextgenShowcaseThemeData t = NextgenShowcaseTheme.of(context);
    final bool glass = t.stunMode;
    final Color baseColor = (t.cardColor) ?? theme.colorScheme.surface;
    final Color cardColor =
        glass ? baseColor.withAlpha(t.cardOpacity.toInt()) : baseColor;
    final BorderRadius radius = BorderRadius.circular(16);

    final MaterialLocalizations l10n = MaterialLocalizations.of(context);
    final ShowcaseConfig? cfg = controller?._config;

    final String prevText = cfg?.previousLabel ?? l10n.backButtonTooltip;
    final String nextText = cfg?.nextLabel ?? l10n.nextPageTooltip;
    final String closeText = cfg?.closeLabel ?? l10n.closeButtonTooltip;

    Widget content = Semantics(
      container: true,
      label: title,
      hint: description,
      child: Container(
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
                IconButton(
                  key: testId != null ? Key('${testId!}-close') : null,
                  tooltip: closeText,
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
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
                TextButton(
                  key: testId != null ? Key('${testId!}-previous') : null,
                  onPressed: onPrevious,
                  child: Text(prevText),
                ),
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
                if ((controller?._config?.showSkipButton ?? true))
                  TextButton(
                    key: testId != null ? Key('${testId!}-skip') : null,
                    onPressed: onClose,
                    child: Text(
                        MaterialLocalizations.of(context).cancelButtonLabel),
                  ),
                const SizedBox(width: 8),
                FilledButton(
                  key: testId != null ? Key('${testId!}-next') : null,
                  onPressed: onNext,
                  child: Text(nextText),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (!glass) return Material(color: Colors.transparent, child: content);

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
              sigmaX: t.glassBlurSigma, sigmaY: t.glassBlurSigma),
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
    final Color cardColor =
        t.stunMode ? baseColor.withAlpha(t.cardOpacity.toInt()) : baseColor;
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
        border:
            t.stunMode ? Border.all(color: Colors.white.withAlpha(20)) : null,
      ),
      child: child,
    );
    if (!t.stunMode) return Material(color: Colors.transparent, child: content);
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
              sigmaX: t.glassBlurSigma, sigmaY: t.glassBlurSigma),
          child: content,
        ),
      ),
    );
  }
}

class _BackdropLayer extends StatelessWidget {
  const _BackdropLayer({
    required this.rect,
    required this.padding,
    required this.borderRadius,
    this.customCutoutPath,
    this.customCutoutBuilder,
    this.backdropBuilder,
  });

  final Rect rect;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final ui.Path? customCutoutPath;
  final ShowcaseCutoutBuilder? customCutoutBuilder;
  final ShowcaseBackdropBuilder? backdropBuilder;

  @override
  Widget build(BuildContext context) {
    final NextgenShowcaseThemeData t = NextgenShowcaseTheme.of(context);
    if ((t.backdropBlurSigma <= 0) && (((t.backdropColor.a * 255).round() & 0xff) == 0)) {
      return const SizedBox.shrink();
    }

    final Rect padded = Rect.fromLTWH(
      rect.left - padding.left,
      rect.top - padding.top,
      rect.width + padding.horizontal,
      rect.height + padding.vertical,
    );

    final Path rectPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        padded,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ));

    Path? customPath;
    if (customCutoutBuilder != null) {
      customPath = customCutoutBuilder!(padded);
    } else if (customCutoutPath != null) {
      customPath = customCutoutPath!;
    }

    final Path shapePath = customPath == null
        ? rectPath
        : Path.combine(PathOperation.union, rectPath, customPath);

    final Widget defaultLayer = ClipPath(
      clipper: _EvenOddClipper(cutout: shapePath),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: t.backdropBlurSigma,
          sigmaY: t.backdropBlurSigma,
        ),
        child: Container(color: Colors.transparent),
      ),
    );

    if (backdropBuilder != null) {
      return backdropBuilder!(
        context,
        padded,
        t,
        defaultLayer,
      );
    }

    return defaultLayer;
  }
}

class _EvenOddClipper extends CustomClipper<Path> {
  _EvenOddClipper({required this.cutout});

  final Path cutout;

  @override
  Path getClip(Size size) {
    final Path p = Path()..fillType = PathFillType.evenOdd;
    p.addRect(Offset.zero & size);
    p.addPath(cutout, Offset.zero);
    return p;
  }

  @override
  bool shouldReclip(covariant _EvenOddClipper oldClipper) =>
      !_arePathsEqual(cutout, oldClipper.cutout);
}

bool _arePathsEqual(Path a, Path b) {
  final ui.PathMetrics am = a.computeMetrics();
  final ui.PathMetrics bm = b.computeMetrics();

  if (am.length != bm.length) return false;

  final List<Offset> pointsA = [];
  for (final m in am) {
    pointsA.add(m.getTangentForOffset(m.length / 2)!.position);
  }

  final List<Offset> pointsB = [];
  for (final m in bm) {
    pointsB.add(m.getTangentForOffset(m.length / 2)!.position);
  }

  return listEquals(pointsA, pointsB);
}

// Removed duplicate private painter; using shared SpotlightPainter
