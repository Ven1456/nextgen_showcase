import 'package:flutter/material.dart';

/// Unified configuration for Nextgen Showcase with sensible defaults and full control.
class ShowcaseConfig {
  const ShowcaseConfig({
    this.backdropColor,
    this.cardColor,
    this.titleStyle,
    this.descriptionStyle,
    this.spotlightShadowColor,
    this.spotlightShadowBlur,
    this.stunMode,
    this.gradientColors,
    this.gradientAnimationMs,
    this.glassBlurSigma,
    this.cardOpacity,
    this.glowPulseDelta,
    this.defaultShape,
    this.defaultBorderRadius,
    this.defaultPadding,
  });

  /// Visual theme options
  final Color? backdropColor;
  final Color? cardColor;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final Color? spotlightShadowColor;
  final double? spotlightShadowBlur;
  final bool? stunMode;
  final List<Color>? gradientColors;
  final int? gradientAnimationMs;
  final double? glassBlurSigma;
  final double? cardOpacity;
  final double? glowPulseDelta;

  /// Step defaults (can be overridden per step)
  final dynamic defaultShape; // late-bound to ShowcaseShape to avoid import cycle
  final BorderRadius? defaultBorderRadius;
  final EdgeInsets? defaultPadding;
}


