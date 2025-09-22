import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models.dart';

/// Advanced background painter that supports various background types.
class AdvancedBackgroundPainter extends CustomPainter {
  /// Creates an advanced background painter.
  const AdvancedBackgroundPainter({
    required this.backgroundType,
    required this.backdropColor,
    required this.backdropBlurSigma,
    required this.gradientColors,
    required this.gradientStops,
    required this.gradientBegin,
    required this.gradientEnd,
    required this.dimOpacity,
    required this.glassBlurSigma,
    required this.animationValue,
    required this.gradientAnimationMs,
    this.customBackgroundBuilder,
  });

  /// Type of background to paint.
  final BackgroundType backgroundType;

  /// Color of the backdrop overlay.
  final Color backdropColor;

  /// Blur sigma for the backdrop.
  final double backdropBlurSigma;

  /// Colors for gradient backgrounds.
  final List<Color> gradientColors;

  /// Gradient stops for gradient backgrounds.
  final List<double>? gradientStops;

  /// Begin alignment for gradient backgrounds.
  final Alignment gradientBegin;

  /// End alignment for gradient backgrounds.
  final Alignment gradientEnd;

  /// Opacity for dimming backgrounds.
  final double dimOpacity;

  /// Blur sigma for glass morphism effect.
  final double glassBlurSigma;

  /// Current animation value for gradient animation.
  final double animationValue;

  /// Duration of gradient animation in milliseconds.
  final int gradientAnimationMs;

  /// Custom background builder.
  final Widget Function(BuildContext context, Size size)? customBackgroundBuilder;

  @override
  void paint(Canvas canvas, Size size) {
    switch (backgroundType) {
      case BackgroundType.solid:
        _paintSolidBackground(canvas, size);
        break;
      case BackgroundType.gradient:
        _paintGradientBackground(canvas, size);
        break;
      case BackgroundType.blur:
        _paintBlurBackground(canvas, size);
        break;
      case BackgroundType.dim:
        _paintDimBackground(canvas, size);
        break;
      case BackgroundType.glass:
        _paintGlassBackground(canvas, size);
        break;
      case BackgroundType.custom:
        // Custom backgrounds are handled by the widget layer
        _paintSolidBackground(canvas, size);
        break;
    }
  }

  /// Paints a solid color background.
  void _paintSolidBackground(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backdropColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  /// Paints a gradient background.
  void _paintGradientBackground(Canvas canvas, Size size) {
    if (gradientColors.isEmpty) {
      _paintSolidBackground(canvas, size);
      return;
    }

    // Animate gradient colors if animation is enabled
    final List<Color> animatedColors = _getAnimatedGradientColors();
    final List<double>? animatedStops = _getAnimatedGradientStops();

    final Gradient gradient = LinearGradient(
      begin: gradientBegin,
      end: gradientEnd,
      colors: animatedColors,
      stops: animatedStops,
    );

    final Paint paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  /// Paints a blur background.
  void _paintBlurBackground(Canvas canvas, Size size) {
    // For blur backgrounds, we paint a solid color and let the BackdropFilter handle the blur
    final Paint paint = Paint()
      ..color = backdropColor.withAlpha(30)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  /// Paints a dimming background.
  void _paintDimBackground(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black.withAlpha(dimOpacity.toInt())
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  /// Paints a glass morphism background.
  void _paintGlassBackground(Canvas canvas, Size size) {
    // Glass morphism combines blur with transparency
    final Paint paint = Paint()
      ..color = backdropColor.withAlpha(10)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  /// Gets animated gradient colors based on the current animation value.
  List<Color> _getAnimatedGradientColors() {
    if (gradientColors.length < 2 || gradientAnimationMs <= 0) {
      return gradientColors;
    }

    final List<Color> animatedColors = [];
    final double cycle = animationValue * gradientColors.length;
    final int currentIndex = cycle.floor() % gradientColors.length;
    final int nextIndex = (currentIndex + 1) % gradientColors.length;
    final double t = cycle - currentIndex;

    for (int i = 0; i < gradientColors.length; i++) {
      if (i == currentIndex) {
        animatedColors.add(Color.lerp(
          gradientColors[currentIndex],
          gradientColors[nextIndex],
          t,
        )!);
      } else {
        animatedColors.add(gradientColors[i]);
      }
    }

    return animatedColors;
  }

  /// Gets animated gradient stops based on the current animation value.
  List<double>? _getAnimatedGradientStops() {
    if (gradientStops == null || gradientStops!.length != gradientColors.length) {
      return null;
    }

    final List<double> animatedStops = [];
    final double cycle = animationValue * gradientStops!.length;
    final int currentIndex = cycle.floor() % gradientStops!.length;
    final int nextIndex = (currentIndex + 1) % gradientStops!.length;
    final double t = cycle - currentIndex;

    for (int i = 0; i < gradientStops!.length; i++) {
      if (i == currentIndex) {
        animatedStops.add(
          gradientStops![currentIndex] + 
          (gradientStops![nextIndex] - gradientStops![currentIndex]) * t
        );
      } else {
        animatedStops.add(gradientStops![i]);
      }
    }

    return animatedStops;
  }

  @override
  bool shouldRepaint(covariant AdvancedBackgroundPainter oldDelegate) {
    return oldDelegate.backgroundType != backgroundType ||
           oldDelegate.backdropColor != backdropColor ||
           oldDelegate.backdropBlurSigma != backdropBlurSigma ||
           oldDelegate.gradientColors != gradientColors ||
           oldDelegate.gradientStops != gradientStops ||
           oldDelegate.gradientBegin != gradientBegin ||
           oldDelegate.gradientEnd != gradientEnd ||
           oldDelegate.dimOpacity != dimOpacity ||
           oldDelegate.glassBlurSigma != glassBlurSigma ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.gradientAnimationMs != gradientAnimationMs ||
           oldDelegate.customBackgroundBuilder != customBackgroundBuilder;
  }
}

/// Custom painter for animated gradient backgrounds.
class AnimatedGradientPainter extends CustomPainter {
  /// Creates an animated gradient painter.
  const AnimatedGradientPainter({
    required this.gradientColors,
    required this.gradientStops,
    required this.gradientBegin,
    required this.gradientEnd,
    required this.animationValue,
    required this.animationDuration,
  });

  /// Colors for the gradient.
  final List<Color> gradientColors;

  /// Gradient stops.
  final List<double>? gradientStops;

  /// Begin alignment for the gradient.
  final Alignment gradientBegin;

  /// End alignment for the gradient.
  final Alignment gradientEnd;

  /// Current animation value.
  final double animationValue;

  /// Duration of the animation.
  final Duration animationDuration;

  @override
  void paint(Canvas canvas, Size size) {
    if (gradientColors.isEmpty) return;

    // Create a rotating gradient effect
    final double rotation = animationValue * 2 * 3.14159; // Full rotation
    final Alignment rotatedBegin = Alignment(
      gradientBegin.x * math.cos(rotation) - gradientBegin.y * math.sin(rotation),
      gradientBegin.x * math.sin(rotation) + gradientBegin.y * math.cos(rotation),
    );
    final Alignment rotatedEnd = Alignment(
      gradientEnd.x * math.cos(rotation) - gradientEnd.y * math.sin(rotation),
      gradientEnd.x * math.sin(rotation) + gradientEnd.y * math.cos(rotation),
    );

    final Gradient gradient = LinearGradient(
      begin: rotatedBegin,
      end: rotatedEnd,
      colors: gradientColors,
      stops: gradientStops,
    );

    final Paint paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedGradientPainter oldDelegate) {
    return oldDelegate.gradientColors != gradientColors ||
           oldDelegate.gradientStops != gradientStops ||
           oldDelegate.gradientBegin != gradientBegin ||
           oldDelegate.gradientEnd != gradientEnd ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.animationDuration != animationDuration;
  }
}
