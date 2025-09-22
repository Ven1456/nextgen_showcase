import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'models.dart';
import 'theme.dart';
import 'config.dart';
import 'storage.dart';
import 'ui/advanced_showcase_overlay.dart';

/// Advanced controller for managing showcase state and navigation with all new features.
///
/// This controller provides comprehensive methods to start, stop, and navigate through
/// showcase steps with support for animations, multi-widget highlighting, accessibility,
/// and advanced interactions.
///
/// Example usage:
/// ```dart
/// final controller = AdvancedShowcaseController();
///
/// // Start the showcase with advanced features
/// controller.startAdvanced(context);
///
/// // Navigate with animations
/// controller.nextWithAnimation(context);
///
/// // Handle multi-widget highlighting
/// controller.highlightMultiple(context, [key1, key2, key3]);
/// ```
class AdvancedShowcaseController extends ChangeNotifier {
  /// Creates an advanced showcase controller.
  ///
  /// The [config] parameter is optional and allows setting default
  /// configuration that can be overridden later.
  AdvancedShowcaseController({ShowcaseConfig? config}) : _config = config;

  OverlayEntry? _activeEntry;
  final List<ShowcaseStep> _steps = <ShowcaseStep>[];
  int _currentIndex = -1;
  ShowcaseConfig? _config;
  ShowcaseStorage? _storage;
  
  // Animation controllers
  late AnimationController _highlightAnimationController;
  late AnimationController _gradientAnimationController;
  late AnimationController _transitionController;
  
  // Animation values
  double _highlightAnimationValue = 0.0;
  double _gradientAnimationValue = 0.0;
  double _transitionAnimationValue = 0.0;
  
  // Multi-widget support
  final List<GlobalKey> _multiHighlightKeys = [];
  final List<Rect> _multiHighlightRects = [];
  
  // Auto-advance support
  Timer? _autoAdvanceTimer;
  
  // Accessibility support
  bool _accessibilityEnabled = true;
  String? _currentAnnouncement;

  // Lifecycle callbacks
  ValueChanged<int>? onStepStart;
  ValueChanged<int>? onStepComplete;
  VoidCallback? onShowcaseEnd;
  ValueChanged<String>? onAccessibilityAnnouncement;
  
  // Advanced event callbacks
  VoidCallback? onHighlightStart;
  VoidCallback? onHighlightEnd;
  ValueChanged<Rect>? onHighlightChanged;
  VoidCallback? onMultiHighlightStart;
  VoidCallback? onMultiHighlightEnd;

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

  /// Current highlight animation value (0.0 to 1.0).
  double get highlightAnimationValue => _highlightAnimationValue;

  /// Current gradient animation value (0.0 to 1.0).
  double get gradientAnimationValue => _gradientAnimationValue;

  /// Current transition animation value (0.0 to 1.0).
  double get transitionAnimationValue => _transitionAnimationValue;

  /// Whether multi-widget highlighting is active.
  bool get isMultiHighlighting => _multiHighlightKeys.isNotEmpty;

  /// List of currently highlighted widget keys.
  List<GlobalKey> get multiHighlightKeys => List.unmodifiable(_multiHighlightKeys);

  /// Whether accessibility announcements are enabled.
  bool get accessibilityEnabled => _accessibilityEnabled;

  /// Sets the list of showcase steps.
  ///
  /// This replaces any existing steps with the new list.
  /// Call this method when you need to update the showcase steps.
  void setSteps(List<ShowcaseStep> steps) {
    _steps
      ..clear()
      ..addAll(steps);
    notifyListeners();
  }

  /// Update configuration while running.
  void setConfig(ShowcaseConfig? config) {
    _config = config;
    if ((config?.persistenceKey != null) &&
        (config?.enablePersistence ?? true)) {
      _storage ??= SharedPrefsShowcaseStorage();
    }
    notifyListeners();
  }

  /// Initialize animation controllers with a TickerProvider.
  void initializeAnimations(TickerProvider vsync) {
    _highlightAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    );

    _gradientAnimationController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: vsync,
    );

    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    );

    // Listen to animation changes
    _highlightAnimationController.addListener(() {
      _highlightAnimationValue = _highlightAnimationController.value;
      notifyListeners();
    });

    _gradientAnimationController.addListener(() {
      _gradientAnimationValue = _gradientAnimationController.value;
      notifyListeners();
    });

    _transitionController.addListener(() {
      _transitionAnimationValue = _transitionController.value;
      notifyListeners();
    });
  }

  /// Dispose animation controllers.
  void disposeAnimations() {
    _highlightAnimationController.dispose();
    _gradientAnimationController.dispose();
    _transitionController.dispose();
    _autoAdvanceTimer?.cancel();
  }

  /// Enable or disable accessibility announcements.
  void setAccessibilityEnabled(bool enabled) {
    _accessibilityEnabled = enabled;
    notifyListeners();
  }

  /// Start the advanced showcase with enhanced features.
  void startAdvanced(BuildContext context, {int initialIndex = 0}) {
    if (_steps.isEmpty) return;

    // Ensure any existing overlay is removed
    if (_activeEntry != null) {
      _activeEntry!.remove();
      _activeEntry = null;
    }

    _currentIndex = initialIndex.clamp(0, _steps.length - 1);
    
    // Check if showcase should be skipped due to persistence
    _maybeSkipShowcase().then((bool skip) {
      if (skip) return;
      _showCurrentAdvanced(context);
    });
  }

  /// Start highlighting multiple widgets simultaneously.
  void highlightMultiple(BuildContext context, List<GlobalKey> keys) {
    if (keys.isEmpty) return;

    _multiHighlightKeys.clear();
    _multiHighlightKeys.addAll(keys);
    
    // Calculate rectangles for all highlighted widgets
    _calculateMultiHighlightRects();
    
    onMultiHighlightStart?.call();
    _showMultiHighlightOverlay(context);
  }

  /// Stop multi-widget highlighting.
  void stopMultiHighlight() {
    if (_activeEntry != null) {
      _activeEntry!.remove();
      _activeEntry = null;
    }
    
    _multiHighlightKeys.clear();
    _multiHighlightRects.clear();
    
    onMultiHighlightEnd?.call();
    notifyListeners();
  }

  /// Navigate to the next step with animation.
  void nextWithAnimation(BuildContext context) {
    if (_currentIndex < 0) return;
    
    // Start transition animation
    _transitionController.forward().then((_) {
      if (_currentIndex + 1 >= _steps.length) {
        onStepComplete?.call(_currentIndex);
        dismiss();
      } else {
        onStepComplete?.call(_currentIndex);
        _currentIndex += 1;
        _transitionController.reset();
        _showCurrentAdvanced(context);
      }
    });
  }

  /// Navigate to the previous step with animation.
  void previousWithAnimation(BuildContext context) {
    if (_currentIndex <= 0) return;
    
    _transitionController.forward().then((_) {
      _currentIndex -= 1;
      _transitionController.reset();
      _showCurrentAdvanced(context);
    });
  }

  /// Start highlight animation for the current step.
  void startHighlightAnimation() {
    final ShowcaseStep? step = currentStep;
    if (step == null) return;

    onHighlightStart?.call();
    
    switch (step.highlightAnimation) {
      case HighlightAnimation.none:
        break;
      case HighlightAnimation.scale:
      case HighlightAnimation.pulse:
      case HighlightAnimation.glow:
        _highlightAnimationController.repeat(reverse: true);
        break;
      case HighlightAnimation.bounce:
        _highlightAnimationController.forward().then((_) {
          _highlightAnimationController.reverse();
        });
        break;
      case HighlightAnimation.elastic:
        _highlightAnimationController.forward();
        break;
      case HighlightAnimation.custom:
        // Custom animation is handled by the step's customAnimation property
        break;
    }
  }

  /// Stop highlight animation.
  void stopHighlightAnimation() {
    _highlightAnimationController.stop();
    onHighlightEnd?.call();
  }

  /// Start gradient animation for stun mode.
  void startGradientAnimation() {
    _gradientAnimationController.repeat();
  }

  /// Stop gradient animation.
  void stopGradientAnimation() {
    _gradientAnimationController.stop();
  }

  /// Set up auto-advance for the current step.
  void setupAutoAdvance(BuildContext context) {
    final ShowcaseStep? step = currentStep;
    if (step == null || !step.autoAdvance) return;

    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(step.autoAdvanceDelay, () {
      nextWithAnimation(context);
    });
  }

  /// Cancel auto-advance timer.
  void cancelAutoAdvance() {
    _autoAdvanceTimer?.cancel();
  }

  /// Announce text for accessibility.
  void announceForAccessibility(String text) {
    if (!_accessibilityEnabled) return;
    
    _currentAnnouncement = text;
    onAccessibilityAnnouncement?.call(text);
    
    // Use Flutter's semantics to announce
    SemanticsService.announce(text, TextDirection.ltr);
  }

  /// Handle tap on highlighted widget.
  void handleTapHighlight() {
    final ShowcaseStep? step = currentStep;
    if (step == null) return;

    step.onTapHighlight?.call();
    
    if (step.allowTapHighlight) {
      // Allow the tap to pass through to the widget
      return;
    }
    
    // Block the tap and show feedback
    announceForAccessibility('Highlighted widget tapped');
  }

  /// Handle tap outside the showcase area.
  void handleTapOutside() {
    final ShowcaseStep? step = currentStep;
    if (step == null) return;

    step.onTapOutside?.call();
    
    if (step.allowTapOutside) {
      dismiss();
    }
  }

  /// Handle gesture navigation.
  void handleGestureNavigation(DragEndDetails details,BuildContext context) {
    final ShowcaseStep? step = currentStep;
    if (step == null || !step.gestureSupport) return;

    final double velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() > 500) {
      if (velocity > 0) {
        previousWithAnimation(context);
      } else {
        nextWithAnimation(context);
      }
    }
  }

  /// Dismiss the current showcase.
  void dismiss() {
    _activeEntry?.remove();
    _activeEntry = null;
    _currentIndex = -1;
    
    // Stop all animations
    stopHighlightAnimation();
    stopGradientAnimation();
    cancelAutoAdvance();
    
    // Clear multi-highlight state
    _multiHighlightKeys.clear();
    _multiHighlightRects.clear();
    
    onShowcaseEnd?.call();
    _markCompleted();
    notifyListeners();
  }

  /// Request rebuild of the overlay if visible.
  void rebuild(BuildContext context) {
    if (_activeEntry != null) {
      _activeEntry!.markNeedsBuild();
    }
  }

  /// Calculate rectangles for multi-widget highlighting.
  void _calculateMultiHighlightRects() {
    _multiHighlightRects.clear();
    
    for (final key in _multiHighlightKeys) {
      final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        final Size size = renderBox.size;
        _multiHighlightRects.add(Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height));
      }
    }
  }

  /// Show the current step with advanced overlay.
  void _showCurrentAdvanced(BuildContext context) {
    final ShowcaseStep step = _steps[_currentIndex];

    // Ensure the target is visible
    _ensureTargetVisible(step);

    // Calculate target rectangle
    final Rect? targetRect = _calculateTargetRect(step);
    if (targetRect == null) {
      _handleMissingTarget(context);
      return;
    }

    // Remove any existing overlay
    if (_activeEntry != null) {
      _activeEntry!.remove();
      _activeEntry = null;
    }

    final NextgenShowcaseThemeData baseTheme = NextgenShowcaseTheme.of(context);
    final NextgenShowcaseThemeData mergedTheme = _mergeTheme(baseTheme, _config);
    // Create advanced overlay
    _activeEntry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        
        return NextgenShowcaseTheme(
          data: mergedTheme,
          child: RepaintBoundary(
            child: AdvancedShowcaseOverlay(
              step: step,
              spotlightRect: targetRect,
              theme: mergedTheme,
              onNext: () => nextWithAnimation(context),
              onPrevious: () => previousWithAnimation(context),
              onSkip: () => dismiss(),
              onClose: () => dismiss(),
              onTapHighlight: handleTapHighlight,
              onTapOutside: handleTapOutside,
              animationValue: _highlightAnimationValue,
              gradientAnimationValue: _gradientAnimationValue,
              isActive: true,
            ),
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_activeEntry!);
    
    // Start animations
    startHighlightAnimation();
    if (mergedTheme.stunMode) {
      startGradientAnimation();
    }
    
    // Set up auto-advance
    setupAutoAdvance(context);
    
    // Announce for accessibility
    announceForAccessibility('${step.title}. ${step.description}');
    
    onStepStart?.call(_currentIndex);
    onHighlightChanged?.call(targetRect);
    notifyListeners();
  }

  /// Show multi-widget highlight overlay.
  void _showMultiHighlightOverlay(BuildContext context) {
    if (_multiHighlightRects.isEmpty) return;

    // Remove any existing overlay
    if (_activeEntry != null) {
      _activeEntry!.remove();
      _activeEntry = null;
    }
    final NextgenShowcaseThemeData baseTheme = NextgenShowcaseTheme.of(context);
    final NextgenShowcaseThemeData mergedTheme = _mergeTheme(baseTheme, _config);
    // Create multi-widget overlay
    _activeEntry = OverlayEntry(
      builder: (BuildContext overlayContext) {

        
        // Create a dummy step for multi-widget highlighting
        final ShowcaseStep multiStep = ShowcaseStep(
          key: _multiHighlightKeys.first,
          title: 'Multiple Widgets',
          description: 'Multiple widgets are highlighted',
        );
        
        return NextgenShowcaseTheme(
          data: mergedTheme,
          child: RepaintBoundary(
            child: MultiWidgetHighlightOverlay(
              highlightRects: _multiHighlightRects,
              step: multiStep,
              theme: mergedTheme,
              onNext: () => nextWithAnimation(context),
              onPrevious: () => previousWithAnimation(context),
              onSkip: () => stopMultiHighlight(),
              onClose: () => stopMultiHighlight(),
              onTapHighlight: handleTapHighlight,
              onTapOutside: handleTapOutside,
              animationValue: _highlightAnimationValue,
            ),
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_activeEntry!);
    
    // Start animations
    startHighlightAnimation();
    if (mergedTheme.stunMode) {
      startGradientAnimation();
    }
    
    notifyListeners();
  }

  /// Ensure the target widget is visible in scrollable areas.
  void _ensureTargetVisible(ShowcaseStep step) {
    final BuildContext? targetContext = step.key.currentContext;
    if (targetContext != null) {
      final ScrollableState? scrollable = Scrollable.maybeOf(targetContext);
      if (scrollable != null) {
        Scrollable.ensureVisible(
          targetContext,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  /// Calculate the target rectangle for a step.
  Rect? _calculateTargetRect(ShowcaseStep step) {
    final RenderBox? renderBox = step.key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
  }

  /// Handle missing target with retry logic.
  void _handleMissingTarget(BuildContext context) {
    final ShowcaseStep step = _steps[_currentIndex];
    final int waitMs = _config?.waitForAsyncMs ?? 150;
    final int maxRetries = _config?.retryMissingTargetMax ?? 5;
    int tries = 0;

    void attempt() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final Rect? rect = _calculateTargetRect(step);
        if (rect == null) {
          tries += 1;
          if (tries < maxRetries) {
            await Future<void>.delayed(Duration(milliseconds: waitMs));
            attempt();
          } else {
            if (kDebugMode) {
              print('[AdvancedShowcase] Target not found for step $_currentIndex. Skipping.');
            }
            if (_currentIndex + 1 < _steps.length) {
              onStepComplete?.call(_currentIndex);
              _currentIndex += 1;
              _showCurrentAdvanced(context);
            } else {
              dismiss();
            }
          }
        } else {
          _showCurrentAdvanced(context);
        }
      });
    }

    attempt();
  }

  /// Check if showcase should be skipped due to persistence.
  Future<bool> _maybeSkipShowcase() async {
    final ShowcaseConfig? cfg = _config;
    if (cfg == null) return false;
    if (cfg.persistenceKey == null) return false;
    if (!(cfg.enablePersistence ?? true)) return false;
    
    final bool? seen = await (_storage ?? SharedPrefsShowcaseStorage())
        .readBool('${cfg.persistenceKey!}__completed');
    return seen == true;
  }

  /// Mark showcase as completed for persistence.
  Future<void> _markCompleted() async {
    final ShowcaseConfig? cfg = _config;
    if (cfg == null) return;
    if (cfg.persistenceKey == null) return;
    if (!(cfg.enablePersistence ?? true)) return;
    
    await (_storage ?? SharedPrefsShowcaseStorage())
        .writeBool('${cfg.persistenceKey!}__completed', true);
  }

  /// Merge theme with configuration.
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

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }
}
