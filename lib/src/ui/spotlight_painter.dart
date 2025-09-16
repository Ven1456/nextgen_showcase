import 'package:flutter/material.dart';

import '../models.dart';

class SpotlightPainter extends CustomPainter {
  SpotlightPainter({
    required this.rect,
    required this.borderRadius,
    required this.padding,
    this.customCutoutPath,
    this.customCutoutBuilder,
    this.stunMode = false,
    this.backdropColor = const Color(0xCC000000),
    this.gradientColors = const <Color>[Colors.black],
    this.gradientT = 0,
  });

  final Rect rect;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Path? customCutoutPath;
  final ShowcaseCutoutBuilder? customCutoutBuilder;
  final bool stunMode;
  final Color backdropColor;
  final List<Color> gradientColors;
  final double gradientT;

  @override
  void paint(Canvas canvas, Size size) {
    final Path backdrop = Path()..addRect(Offset.zero & size);
    final Path cutout = Path()..fillType = PathFillType.evenOdd;

    final Rect padded = Rect.fromLTWH(
      rect.left - padding.left,
      rect.top - padding.top,
      rect.width + padding.horizontal,
      rect.height + padding.vertical,
    );

    // Base spotlight is a rounded rectangle around the target.
    final Path rectPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        padded,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ));

    // Allow user to draw a custom shape, and connect/union it with the base rect.
    Path? customPath;
    if (customCutoutBuilder != null) {
      customPath = customCutoutBuilder!(padded);
    } else if (customCutoutPath != null) {
      customPath = customCutoutPath!;
    }

    final Path shapePath = customPath == null
        ? rectPath
        : Path.combine(PathOperation.union, rectPath, customPath);

    cutout
      ..addPath(backdrop, Offset.zero)
      ..addPath(shapePath, Offset.zero);

    final Paint dimPaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.dstOut;

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

    // No spotlight blur/shadow; kept intentionally clean per requirements.
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return rect != oldDelegate.rect ||
        borderRadius != oldDelegate.borderRadius ||
        padding != oldDelegate.padding ||
        gradientT != oldDelegate.gradientT ||
        gradientColors != oldDelegate.gradientColors ||
        backdropColor != oldDelegate.backdropColor ||
        stunMode != oldDelegate.stunMode;
  }
}


