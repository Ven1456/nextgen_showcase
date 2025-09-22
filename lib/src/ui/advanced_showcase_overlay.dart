import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models.dart';
import '../theme.dart';
import 'advanced_spotlight_painter.dart';
import 'advanced_background_painter.dart';
import 'advanced_tooltip.dart';

/// Advanced showcase overlay that combines all the new features.
class AdvancedShowcaseOverlay extends StatefulWidget {
  /// Creates an advanced showcase overlay.
  const AdvancedShowcaseOverlay({
    super.key,
    required this.step,
    required this.spotlightRect,
    required this.theme,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
    required this.onClose,
    required this.onTapHighlight,
    required this.onTapOutside,
    this.animationValue = 0.0,
    this.gradientAnimationValue = 0.0,
    this.isActive = true,
  });

  /// The showcase step configuration.
  final ShowcaseStep step;

  /// The rectangle of the spotlight area.
  final Rect spotlightRect;

  /// The theme for the showcase.
  final NextgenShowcaseThemeData theme;

  /// Callback for next action.
  final VoidCallback onNext;

  /// Callback for previous action.
  final VoidCallback onPrevious;

  /// Callback for skip action.
  final VoidCallback onSkip;

  /// Callback for close action.
  final VoidCallback onClose;

  /// Callback for tap on highlight.
  final VoidCallback onTapHighlight;

  /// Callback for tap outside.
  final VoidCallback onTapOutside;

  /// Current animation value for highlight animations.
  final double animationValue;

  /// Current animation value for gradient animations.
  final double gradientAnimationValue;

  /// Whether the overlay is currently active.
  final bool isActive;

  @override
  State<AdvancedShowcaseOverlay> createState() => _AdvancedShowcaseOverlayState();
}

class _AdvancedShowcaseOverlayState extends State<AdvancedShowcaseOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _gradientController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: widget.theme.animationDuration,
      vsync: this,
    );

    _gradientController = AnimationController(
      duration: Duration(milliseconds: widget.theme.gradientAnimationMs),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: widget.theme.animationCurve,
    ));

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_gradientController);

    if (widget.isActive) {
      _fadeController.forward();
      if (widget.theme.stunMode) {
        _gradientController.repeat();
      }
    }
  }

  @override
  void didUpdateWidget(AdvancedShowcaseOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _fadeController.forward();
        if (widget.theme.stunMode) {
          _gradientController.repeat();
        }
      } else {
        _fadeController.reverse();
        _gradientController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background layer
          _buildBackgroundLayer(),
          
          // Spotlight layer
          _buildSpotlightLayer(),
          
          // Tooltip layer
          _buildTooltipLayer(),
          
          // Interaction layer
          _buildInteractionLayer(),
        ],
      ),
    );
  }

  Widget _buildBackgroundLayer() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: AdvancedBackgroundPainter(
              backgroundType: widget.theme.backgroundType,
              backdropColor: widget.theme.backdropColor,
              backdropBlurSigma: widget.theme.backdropBlurSigma,
              gradientColors: widget.theme.gradientColors,
              gradientStops: widget.theme.gradientStops,
              gradientBegin: widget.theme.gradientBegin,
              gradientEnd: widget.theme.gradientEnd,
              dimOpacity: widget.theme.dimOpacity,
              glassBlurSigma: widget.theme.glassBlurSigma,
              animationValue: _gradientAnimation.value,
              gradientAnimationMs: widget.theme.gradientAnimationMs,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpotlightLayer() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: AdvancedSpotlightPainter(
              spotlightRect: widget.spotlightRect,
              shape: widget.step.shape,
              borderRadius: widget.step.borderRadius,
              padding: widget.step.padding,
              spotlightShadowColor: widget.theme.spotlightShadowColor,
              spotlightShadowBlur: widget.theme.spotlightShadowBlur,
              highlightAnimation: widget.step.highlightAnimation,
              animationValue: widget.animationValue,
              polygonSides: widget.step.polygonSides,
              starPoints: widget.step.starPoints,
              starInnerRadius: widget.step.starInnerRadius,
              customCutoutPath: widget.step.customCutoutPath,
              customCutoutBuilder: widget.step.customCutoutBuilder,
              glowPulseDelta: widget.theme.glowPulseDelta,
              holePunchTransparency: widget.theme.holePunchTransparency,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTooltipLayer() {
    if (!widget.isActive) return const SizedBox.shrink();

    return AdvancedTooltip(
      step: widget.step,
      spotlightRect: widget.spotlightRect,
      screenSize: MediaQuery.of(context).size,
      theme: widget.theme,
      onNext: widget.onNext,
      onPrevious: widget.onPrevious,
      onSkip: widget.onSkip,
      onClose: widget.onClose,
      onTapHighlight: widget.onTapHighlight,
      onTapOutside: widget.onTapOutside,
    );
  }

  Widget _buildInteractionLayer() {
    return GestureDetector(
      onTap: () {
        // Tap anywhere advances to next step; controller will close on last
        widget.onNext();
      },
      onPanUpdate: (details) {
        if (widget.step.gestureSupport) {
          // Handle swipe gestures for navigation
          final double deltaX = details.delta.dx;
          if (deltaX.abs() > 50) {
            if (deltaX > 0) {
              widget.onPrevious();
            } else {
              widget.onNext();
            }
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: _buildHighlightInteraction(),
      ),
    );
  }

  Widget _buildHighlightInteraction() {
    if (!widget.step.allowTapHighlight) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: widget.spotlightRect.left,
      top: widget.spotlightRect.top,
      child: GestureDetector(
        onTap: () {
          widget.onTapHighlight();
          // Also advance to next on highlight tap
          widget.onNext();
        },
        child: Container(
          width: widget.spotlightRect.width,
          height: widget.spotlightRect.height,
          color: Colors.transparent,
        ),
      ),
    );
  }
}

/// Advanced showcase overlay with blur effects.
class BlurredShowcaseOverlay extends StatelessWidget {
  /// Creates a blurred showcase overlay.
  const BlurredShowcaseOverlay({
    super.key,
    required this.child,
    required this.blurSigma,
    required this.isActive,
  });

  /// The child widget to display.
  final Widget child;

  /// The blur sigma value.
  final double blurSigma;

  /// Whether the blur is active.
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (!isActive || blurSigma <= 0) {
      return child;
    }

    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: child,
    );
  }
}

/// Glass morphism showcase overlay.
class GlassMorphismOverlay extends StatelessWidget {
  /// Creates a glass morphism overlay.
  const GlassMorphismOverlay({
    super.key,
    required this.child,
    required this.blurSigma,
    required this.opacity,
    required this.gradientColors,
    required this.animationValue,
  });

  /// The child widget to display.
  final Widget child;

  /// The blur sigma value.
  final double blurSigma;

  /// The opacity of the overlay.
  final double opacity;

  /// The gradient colors for the glass effect.
  final List<Color> gradientColors;

  /// The animation value for the gradient.
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors.map((color) => 
                  color.withAlpha(opacity.toInt())).toList(),
                stops: List.generate(gradientColors.length, (index) => 
                  index / (gradientColors.length - 1)),
              ),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

/// Multi-widget highlight overlay for highlighting multiple widgets simultaneously.
class MultiWidgetHighlightOverlay extends StatefulWidget {
  /// Creates a multi-widget highlight overlay.
  const MultiWidgetHighlightOverlay({
    super.key,
    required this.highlightRects,
    required this.step,
    required this.theme,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
    required this.onClose,
    required this.onTapHighlight,
    required this.onTapOutside,
    this.animationValue = 0.0,
  });

  /// The rectangles of all highlighted widgets.
  final List<Rect> highlightRects;

  /// The showcase step configuration.
  final ShowcaseStep step;

  /// The theme for the showcase.
  final NextgenShowcaseThemeData theme;

  /// Callback for next action.
  final VoidCallback onNext;

  /// Callback for previous action.
  final VoidCallback onPrevious;

  /// Callback for skip action.
  final VoidCallback onSkip;

  /// Callback for close action.
  final VoidCallback onClose;

  /// Callback for tap on highlight.
  final VoidCallback onTapHighlight;

  /// Callback for tap outside.
  final VoidCallback onTapOutside;

  /// Current animation value.
  final double animationValue;

  @override
  State<MultiWidgetHighlightOverlay> createState() => _MultiWidgetHighlightOverlayState();
}

class _MultiWidgetHighlightOverlayState extends State<MultiWidgetHighlightOverlay> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background layer
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: MultiWidgetBackgroundPainter(
              highlightRects: widget.highlightRects,
              backdropColor: widget.theme.backdropColor,
              backdropBlurSigma: widget.theme.backdropBlurSigma,
            ),
          ),
          
          // Spotlight layer for each widget
          ...widget.highlightRects.map((rect) => 
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: AdvancedSpotlightPainter(
                spotlightRect: rect,
                shape: widget.step.shape,
                borderRadius: widget.step.borderRadius,
                padding: widget.step.padding,
                spotlightShadowColor: widget.theme.spotlightShadowColor,
                spotlightShadowBlur: widget.theme.spotlightShadowBlur,
                highlightAnimation: widget.step.highlightAnimation,
                animationValue: widget.animationValue,
                polygonSides: widget.step.polygonSides,
                starPoints: widget.step.starPoints,
                starInnerRadius: widget.step.starInnerRadius,
                customCutoutPath: widget.step.customCutoutPath,
                customCutoutBuilder: widget.step.customCutoutBuilder,
                glowPulseDelta: widget.theme.glowPulseDelta,
                holePunchTransparency: widget.theme.holePunchTransparency,
              ),
            ),
          ),
          
          // Tooltip layer
          AdvancedTooltip(
            step: widget.step,
            spotlightRect: _calculateCombinedRect(),
            screenSize: MediaQuery.of(context).size,
            theme: widget.theme,
            onNext: widget.onNext,
            onPrevious: widget.onPrevious,
            onSkip: widget.onSkip,
            onClose: widget.onClose,
            onTapHighlight: widget.onTapHighlight,
            onTapOutside: widget.onTapOutside,
          ),

          // Full-screen gesture layer to advance on tap anywhere
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: widget.onNext,
            ),
          ),
        ],
      ),
    );
  }

  Rect _calculateCombinedRect() {
    if (widget.highlightRects.isEmpty) {
      return Rect.zero;
    }

    double left = widget.highlightRects.first.left;
    double top = widget.highlightRects.first.top;
    double right = widget.highlightRects.first.right;
    double bottom = widget.highlightRects.first.bottom;

    for (final rect in widget.highlightRects) {
      left = math.min(left, rect.left);
      top = math.min(top, rect.top);
      right = math.max(right, rect.right);
      bottom = math.max(bottom, rect.bottom);
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }
}

/// Custom painter for multi-widget backgrounds.
class MultiWidgetBackgroundPainter extends CustomPainter {
  /// Creates a multi-widget background painter.
  const MultiWidgetBackgroundPainter({
    required this.highlightRects,
    required this.backdropColor,
    required this.backdropBlurSigma,
  });

  final List<Rect> highlightRects;
  final Color backdropColor;
  final double backdropBlurSigma;

  @override
  void paint(Canvas canvas, Size size) {
    // Create cutout paths for all highlighted widgets
    final Path cutoutPath = Path();
    for (final rect in highlightRects) {
      cutoutPath.addRect(rect);
    }

    // Create the backdrop path (full screen minus cutouts)
    final Path backdropPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addPath(cutoutPath, Offset.zero)
      ..fillType = ui.PathFillType.evenOdd;

    // Paint the backdrop
    final Paint backdropPaint = Paint()
      ..color = backdropColor
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(backdropPath, backdropPaint);
  }

  @override
  bool shouldRepaint(covariant MultiWidgetBackgroundPainter oldDelegate) {
    return oldDelegate.highlightRects != highlightRects ||
           oldDelegate.backdropColor != backdropColor ||
           oldDelegate.backdropBlurSigma != backdropBlurSigma;
  }
}
