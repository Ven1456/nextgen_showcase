import 'package:flutter/material.dart';

/// An inherited widget that provides theme data for showcase widgets.
///
/// This widget makes theme data available to all showcase widgets in the
/// widget tree below it.
class NextgenShowcaseTheme extends InheritedWidget {
  /// Creates a showcase theme widget.
  ///
  /// The [data] and [child] parameters are required.
  const NextgenShowcaseTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The theme data for showcase widgets.
  final NextgenShowcaseThemeData data;

  /// Returns the showcase theme data from the nearest [NextgenShowcaseTheme]
  /// ancestor, or the default theme if none is found.
  static NextgenShowcaseThemeData of(BuildContext context) {
    final NextgenShowcaseTheme? theme =
        context.dependOnInheritedWidgetOfExactType<NextgenShowcaseTheme>();
    return theme?.data ?? const NextgenShowcaseThemeData();
  }

  /// Returns a theme data resolved against the current Material [Theme] (e.g., brightness).
  static NextgenShowcaseThemeData resolved(BuildContext context) {
    final NextgenShowcaseThemeData base = of(context);
    return base.resolvedFor(context);
  }

  @override
  bool updateShouldNotify(covariant NextgenShowcaseTheme oldWidget) =>
      data != oldWidget.data;
}

/// Theme data for showcase widgets.
///
/// This class defines the visual appearance and behavior of showcase widgets.
/// It provides sensible defaults while allowing full customization.
class NextgenShowcaseThemeData {
  /// Creates theme data for showcase widgets.
  ///
  /// All parameters have sensible defaults and are optional.
  const NextgenShowcaseThemeData({
    this.backdropColor = const Color(0xCC000000),
    this.cardColor,
    this.titleStyle,
    this.descriptionStyle,
    this.spotlightShadowColor = const Color(0x80000000),
    this.spotlightShadowBlur = 24,
    this.stunMode = false,
    this.gradientColors = const <Color>[
      Color(0xFF00E5FF),
      Color(0xFF7C4DFF),
      Color(0xFFFF4081)
    ],
    this.gradientAnimationMs = 4000,
    this.glassBlurSigma = 12,
    this.cardOpacity = 0.85,
    this.glowPulseDelta = 10,
  });

  /// The color of the backdrop overlay.
  final Color backdropColor;

  /// The background color of the showcase card.
  final Color? cardColor;

  /// The text style for step titles.
  final TextStyle? titleStyle;

  /// The text style for step descriptions.
  final TextStyle? descriptionStyle;

  /// The color of the spotlight shadow/glow effect.
  final Color spotlightShadowColor;

  /// The blur radius of the spotlight shadow/glow effect.
  final double spotlightShadowBlur;

  /// Whether to enable "stun mode" with glass morphism and gradient effects.
  final bool stunMode;

  /// Colors for the animated gradient effect in stun mode.
  final List<Color> gradientColors;

  /// Duration of the gradient animation in milliseconds.
  final int gradientAnimationMs;

  /// Blur sigma for the glass morphism effect.
  final double glassBlurSigma;

  /// Opacity of the showcase card in stun mode.
  final double cardOpacity;

  /// Delta value for the glow pulse animation.
  final double glowPulseDelta;

  /// Creates a copy of this theme data with the given fields replaced.
  ///
  /// All parameters are optional and will use the current values if not provided.
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

  /// Create a derived theme using ambient Material theme defaults.
  NextgenShowcaseThemeData resolvedFor(BuildContext context) {
    final ThemeData material = Theme.of(context);
    final bool isDark = material.brightness == Brightness.dark;
    final Color resolvedCard = cardColor ?? material.colorScheme.surface;
    final List<Color> resolvedGradient = gradientColors.isNotEmpty
        ? gradientColors
        : (isDark
            ? <Color>[const Color(0xFF263238), const Color(0xFF000000)]
            : <Color>[const Color(0xFFE0F7FA), const Color(0xFFEDE7F6)]);
    final Color resolvedBackdrop = isDark
        ? backdropColor
        : backdropColor.withAlpha(170); // slightly lighter for light mode

    return copyWith(
      cardColor: resolvedCard,
      gradientColors: resolvedGradient,
      backdropColor: resolvedBackdrop,
    );
  }
}
