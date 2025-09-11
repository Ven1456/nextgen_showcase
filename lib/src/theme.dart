import 'package:flutter/material.dart';

class NextgenShowcaseTheme extends InheritedWidget {
  const NextgenShowcaseTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final NextgenShowcaseThemeData data;

  static NextgenShowcaseThemeData of(BuildContext context) {
    final NextgenShowcaseTheme? theme = context.dependOnInheritedWidgetOfExactType<NextgenShowcaseTheme>();
    return theme?.data ?? const NextgenShowcaseThemeData();
  }

  @override
  bool updateShouldNotify(covariant NextgenShowcaseTheme oldWidget) => data != oldWidget.data;
}

class NextgenShowcaseThemeData {
  const NextgenShowcaseThemeData({
    this.backdropColor = const Color(0xCC000000),
    this.cardColor,
    this.titleStyle,
    this.descriptionStyle,
    this.spotlightShadowColor = const Color(0x80000000),
    this.spotlightShadowBlur = 24,
    this.stunMode = false,
    this.gradientColors = const <Color>[Color(0xFF00E5FF), Color(0xFF7C4DFF), Color(0xFFFF4081)],
    this.gradientAnimationMs = 4000,
    this.glassBlurSigma = 12,
    this.cardOpacity = 0.85,
    this.glowPulseDelta = 10,
  });

  final Color backdropColor;
  final Color? cardColor;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final Color spotlightShadowColor;
  final double spotlightShadowBlur;
  final bool stunMode;
  final List<Color> gradientColors;
  final int gradientAnimationMs;
  final double glassBlurSigma;
  final double cardOpacity;
  final double glowPulseDelta;

  NextgenShowcaseThemeData copyWith({
    Color? backdropColor,
    Color? cardColor,
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    Color? spotlightShadowColor,
    double? spotlightShadowBlur,
    bool? stunMode,
    List<Color>? gradientColors,
    int? gradientAnimationMs,
    double? glassBlurSigma,
    double? cardOpacity,
    double? glowPulseDelta,
  }) {
    return NextgenShowcaseThemeData(
      backdropColor: backdropColor ?? this.backdropColor,
      cardColor: cardColor ?? this.cardColor,
      titleStyle: titleStyle ?? this.titleStyle,
      descriptionStyle: descriptionStyle ?? this.descriptionStyle,
      spotlightShadowColor: spotlightShadowColor ?? this.spotlightShadowColor,
      spotlightShadowBlur: spotlightShadowBlur ?? this.spotlightShadowBlur,
      stunMode: stunMode ?? this.stunMode,
      gradientColors: gradientColors ?? this.gradientColors,
      gradientAnimationMs: gradientAnimationMs ?? this.gradientAnimationMs,
      glassBlurSigma: glassBlurSigma ?? this.glassBlurSigma,
      cardOpacity: cardOpacity ?? this.cardOpacity,
      glowPulseDelta: glowPulseDelta ?? this.glowPulseDelta,
    );
  }
}


