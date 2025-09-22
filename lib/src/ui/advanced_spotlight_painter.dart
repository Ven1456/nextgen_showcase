import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models.dart';

/// Advanced spotlight painter that supports all showcase shapes and animations.
class AdvancedSpotlightPainter extends CustomPainter {
  /// Creates an advanced spotlight painter.
  const AdvancedSpotlightPainter({
    required this.spotlightRect,
    required this.shape,
    required this.borderRadius,
    required this.padding,
    required this.spotlightShadowColor,
    required this.spotlightShadowBlur,
    required this.highlightAnimation,
    required this.animationValue,
    required this.polygonSides,
    required this.starPoints,
    required this.starInnerRadius,
    this.customCutoutPath,
    this.customCutoutBuilder,
    this.glowPulseDelta = 10,
    this.holePunchTransparency = true,
  });

  /// The rectangle of the spotlight area.
  final Rect spotlightRect;

  /// The shape of the spotlight.
  final ShowcaseShape shape;

  /// Border radius for rounded shapes.
  final BorderRadius borderRadius;

  /// Padding around the spotlight area.
  final EdgeInsets padding;

  /// Color of the spotlight shadow/glow effect.
  final Color spotlightShadowColor;

  /// Blur radius of the spotlight shadow/glow effect.
  final double spotlightShadowBlur;

  /// Animation type for the highlight effect.
  final HighlightAnimation highlightAnimation;

  /// Current animation value (0.0 to 1.0).
  final double animationValue;

  /// Number of sides for polygon shape.
  final int polygonSides;

  /// Number of points for star shape.
  final int starPoints;

  /// Inner radius ratio for star shape.
  final double starInnerRadius;

  /// Custom path for the spotlight cutout.
  final ui.Path? customCutoutPath;

  /// Custom path builder for the spotlight cutout.
  final ShowcaseCutoutBuilder? customCutoutBuilder;

  /// Delta value for glow pulse animation.
  final double glowPulseDelta;

  /// Whether the highlight cutout should be transparent.
  final bool holePunchTransparency;

  @override
  void paint(Canvas canvas, Size size) {
    if (spotlightRect.isEmpty) return;

    final Rect paddedRect = _applyPadding(spotlightRect);
    final ui.Path cutoutPath = _createCutoutPath(paddedRect);
    
    // Apply animation effects
    final ui.Path animatedPath = _applyAnimation(cutoutPath, paddedRect);
    
    // Create the backdrop path (full screen minus cutout)
    final ui.Path backdropPath = ui.Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addPath(animatedPath, Offset.zero)
      ..fillType = ui.PathFillType.evenOdd;

    // Paint the backdrop
    final Paint backdropPaint = Paint()
      ..color = Colors.black.withAlpha(50)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(backdropPath, backdropPaint);

    // Paint the glow effect if enabled
    if (highlightAnimation == HighlightAnimation.glow || 
        highlightAnimation == HighlightAnimation.pulse) {
      _paintGlowEffect(canvas, animatedPath);
    }
  }

  /// Applies padding to the spotlight rectangle.
  Rect _applyPadding(Rect rect) {
    return Rect.fromLTRB(
      rect.left - padding.left,
      rect.top - padding.top,
      rect.right + padding.right,
      rect.bottom + padding.bottom,
    );
  }

  /// Creates the cutout path based on the shape.
  ui.Path _createCutoutPath(Rect rect) {
    switch (shape) {
      case ShowcaseShape.rectangle:
        return _createRectanglePath(rect);
      case ShowcaseShape.roundedRectangle:
        return _createRoundedRectanglePath(rect);
      case ShowcaseShape.circle:
        return _createCirclePath(rect);
      case ShowcaseShape.oval:
        return _createOvalPath(rect);
      case ShowcaseShape.stadium:
        return _createStadiumPath(rect);
      case ShowcaseShape.diamond:
        return _createDiamondPath(rect);
      case ShowcaseShape.polygon:
        return _createPolygonPath(rect);
      case ShowcaseShape.star:
        return _createStarPath(rect);
      case ShowcaseShape.custom:
        if (customCutoutPath != null) {
          return customCutoutPath!;
        } else if (customCutoutBuilder != null) {
          return customCutoutBuilder!(rect);
        } else {
          return _createRoundedRectanglePath(rect);
        }
    }
  }

  /// Creates a rectangle path.
  ui.Path _createRectanglePath(Rect rect) {
    return ui.Path()..addRect(rect);
  }

  /// Creates a rounded rectangle path.
  ui.Path _createRoundedRectanglePath(Rect rect) {
    return ui.Path()..addRRect(RRect.fromRectAndCorners(
      rect,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    ));
  }

  /// Creates a circle path.
  ui.Path _createCirclePath(Rect rect) {
    final double radius = math.min(rect.width, rect.height) / 2;
    final Offset center = rect.center;
    return ui.Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  /// Creates an oval path.
  ui.Path _createOvalPath(Rect rect) {
    return ui.Path()..addOval(rect);
  }

  /// Creates a stadium (pill) path.
  ui.Path _createStadiumPath(Rect rect) {
    final double radius = rect.height / 2;
    return ui.Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
  }

  /// Creates a diamond path.
  ui.Path _createDiamondPath(Rect rect) {
    final ui.Path path = ui.Path();
    final Offset center = rect.center;
    final double halfWidth = rect.width / 2;
    final double halfHeight = rect.height / 2;
    
    path.moveTo(center.dx, center.dy - halfHeight); // Top
    path.lineTo(center.dx + halfWidth, center.dy); // Right
    path.lineTo(center.dx, center.dy + halfHeight); // Bottom
    path.lineTo(center.dx - halfWidth, center.dy); // Left
    path.close();
    
    return path;
  }

  /// Creates a polygon path.
  ui.Path _createPolygonPath(Rect rect) {
    final ui.Path path = ui.Path();
    final Offset center = rect.center;
    final double radius = math.min(rect.width, rect.height) / 2;
    
    for (int i = 0; i < polygonSides; i++) {
      final double angle = (2 * math.pi * i) / polygonSides - math.pi / 2;
      final double x = center.dx + radius * math.cos(angle);
      final double y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    return path;
  }

  /// Creates a star path.
  ui.Path _createStarPath(Rect rect) {
    final ui.Path path = ui.Path();
    final Offset center = rect.center;
    final double outerRadius = math.min(rect.width, rect.height) / 2;
    final double innerRadius = outerRadius * starInnerRadius;
    
    for (int i = 0; i < starPoints * 2; i++) {
      final double angle = (math.pi * i) / starPoints - math.pi / 2;
      final double radius = i.isEven ? outerRadius : innerRadius;
      final double x = center.dx + radius * math.cos(angle);
      final double y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    return path;
  }

  /// Applies animation effects to the path.
  ui.Path _applyAnimation(ui.Path path, Rect rect) {
    switch (highlightAnimation) {
      case HighlightAnimation.none:
        return path;
      case HighlightAnimation.scale:
        return _applyScaleAnimation(path, rect);
      case HighlightAnimation.pulse:
        return _applyPulseAnimation(path, rect);
      case HighlightAnimation.glow:
        return path; // Glow is painted separately
      case HighlightAnimation.bounce:
        return _applyBounceAnimation(path, rect);
      case HighlightAnimation.elastic:
        return _applyElasticAnimation(path, rect);
      case HighlightAnimation.custom:
        return path; // Custom animation is handled externally
    }
  }

  /// Applies scale animation to the path.
  ui.Path _applyScaleAnimation(ui.Path path, Rect rect) {
    final double scale = 0.8 + (0.2 * animationValue);
    final Offset center = rect.center;
    
    final Matrix4 transform = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(scale)
      ..translate(-center.dx, -center.dy);
    
    return path.transform(transform.storage);
  }

  /// Applies pulse animation to the path.
  ui.Path _applyPulseAnimation(ui.Path path, Rect rect) {
    final double pulse = 1.0 + (glowPulseDelta / 100) * math.sin(animationValue * 2 * math.pi);
    final Offset center = rect.center;
    
    final Matrix4 transform = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(pulse)
      ..translate(-center.dx, -center.dy);
    
    return path.transform(transform.storage);
  }

  /// Applies bounce animation to the path.
  ui.Path _applyBounceAnimation(ui.Path path, Rect rect) {
    final double bounce = _bounceCurve(animationValue);
    final Offset center = rect.center;
    
    final Matrix4 transform = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(bounce)
      ..translate(-center.dx, -center.dy);
    
    return path.transform(transform.storage);
  }

  /// Applies elastic animation to the path.
  ui.Path _applyElasticAnimation(ui.Path path, Rect rect) {
    final double elastic = _elasticCurve(animationValue);
    final Offset center = rect.center;
    
    final Matrix4 transform = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(elastic)
      ..translate(-center.dx, -center.dy);
    
    return path.transform(transform.storage);
  }

  /// Paints the glow effect around the path.
  void _paintGlowEffect(Canvas canvas, ui.Path path) {
    final Paint glowPaint = Paint()
      ..color = spotlightShadowColor.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, spotlightShadowBlur);
    
    // Paint multiple glow layers for better effect
    for (int i = 0; i < 3; i++) {
      final double opacity = (0.3 - (i * 0.1)).clamp(0.0, 1.0);
      final double blur = spotlightShadowBlur + (i * 2);
      
      glowPaint.color = spotlightShadowColor.withAlpha(opacity.toInt());
      glowPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
      
      canvas.drawPath(path, glowPaint);
    }
  }

  /// Bounce curve function.
  double _bounceCurve(double t) {
    if (t < 1 / 2.75) {
      return 7.5625 * t * t;
    } else if (t < 2 / 2.75) {
      t -= 1.5 / 2.75;
      return 7.5625 * t * t + 0.75;
    } else if (t < 2.5 / 2.75) {
      t -= 2.25 / 2.75;
      return 7.5625 * t * t + 0.9375;
    } else {
      t -= 2.625 / 2.75;
      return 7.5625 * t * t + 0.984375;
    }
  }

  /// Elastic curve function.
  double _elasticCurve(double t) {
    if (t == 0 || t == 1) return t;
    
    final double p = 0.3;
    final double s = p / 4;
    
    return math.pow(2, -10 * t) * math.sin((t - s) * (2 * math.pi) / p) + 1;
  }

  @override
  bool shouldRepaint(covariant AdvancedSpotlightPainter oldDelegate) {
    return oldDelegate.spotlightRect != spotlightRect ||
           oldDelegate.shape != shape ||
           oldDelegate.borderRadius != borderRadius ||
           oldDelegate.padding != padding ||
           oldDelegate.spotlightShadowColor != spotlightShadowColor ||
           oldDelegate.spotlightShadowBlur != spotlightShadowBlur ||
           oldDelegate.highlightAnimation != highlightAnimation ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.polygonSides != polygonSides ||
           oldDelegate.starPoints != starPoints ||
           oldDelegate.starInnerRadius != starInnerRadius ||
           oldDelegate.customCutoutPath != customCutoutPath ||
           oldDelegate.customCutoutBuilder != customCutoutBuilder ||
           oldDelegate.glowPulseDelta != glowPulseDelta ||
           oldDelegate.holePunchTransparency != holePunchTransparency;
  }
}
