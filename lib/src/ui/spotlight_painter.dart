import 'package:flutter/material.dart';

import '../models.dart';

class SpotlightPainter extends CustomPainter {
  SpotlightPainter({
    required this.rect,
    required this.shape,
    required this.borderRadius,
    required this.padding,
    required this.shadowColor,
    required this.shadowBlur,
    this.customCutoutPath,
    this.customCutoutBuilder,
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
        if (customCutoutBuilder != null) {
          final Path built = customCutoutBuilder!(padded);
          shapePath.addPath(built, Offset.zero);
        } else if (customCutoutPath != null) {
          shapePath.addPath(customCutoutPath!, Offset.zero);
        } else {
          shapePath.addRect(padded);
        }
        break;
    }

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

    canvas.drawShadow(shapePath, shadowColor, shadowBlur, false);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return rect != oldDelegate.rect ||
        shape != oldDelegate.shape ||
        borderRadius != oldDelegate.borderRadius ||
        padding != oldDelegate.padding ||
        shadowColor != oldDelegate.shadowColor ||
        shadowBlur != oldDelegate.shadowBlur ||
        gradientT != oldDelegate.gradientT ||
        gradientColors != oldDelegate.gradientColors ||
        backdropColor != oldDelegate.backdropColor ||
        stunMode != oldDelegate.stunMode;
  }
}


