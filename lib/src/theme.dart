import 'package:flutter/material.dart';
import 'package:nextgen_showcase/src/models.dart';

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
    this.backdropColor = const Color(0xE6000000),
    this.backdropBlurSigma = 0,
    this.cardColor,
    this.titleStyle,
    this.descriptionStyle,
    this.spotlightShadowColor = const Color(0x80000000),
    this.spotlightShadowBlur = 24,
    this.stunMode = false,
    this.gradientColors = const <Color>[
      Color(0xFF667eea),
      Color(0xFF764ba2),
      Color(0xFFf093fb),
      Color(0xFFf5576c)
    ],
    this.gradientAnimationMs = 4000,
    this.glassBlurSigma = 12,
    this.cardOpacity = 0.85,
    this.glowPulseDelta = 10,
    // New advanced theme options
    this.backgroundType = BackgroundType.solid,
    this.gradientStops,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.dimOpacity = 0.7,
    this.holePunchTransparency = true,
    this.animationCurve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 300),
    this.tooltipBackgroundColor,
    this.tooltipBorderColor,
    this.tooltipBorderWidth = 1.0,
    this.tooltipBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.tooltipShadowColor = const Color(0x40000000),
    this.tooltipShadowBlur = 8.0,
    this.tooltipShadowOffset = const Offset(0, 2),
    this.tooltipPadding = const EdgeInsets.all(16),
    this.tooltipMargin = const EdgeInsets.all(8),
    this.arrowSize = 8.0,
    this.arrowColor,
    this.progressIndicatorColor,
    this.progressIndicatorBackgroundColor,
    this.progressIndicatorHeight = 4.0,
    this.buttonStyle,
    this.skipButtonStyle,
    this.nextButtonStyle,
    this.previousButtonStyle,
    this.closeButtonStyle,
    this.rtlSupport = false,
    this.accessibilityAnnouncements = true,
    this.keyboardNavigation = true,
  });

  /// The color of the backdrop overlay.
  final Color backdropColor;

  /// The blur sigma applied to the entire backdrop overlay (behind the dim layer).
  ///
  /// Use 0 to disable backdrop blurring.
  final double backdropBlurSigma;

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

  // New advanced theme properties

  /// Type of background for the showcase overlay.
  final BackgroundType backgroundType;

  /// Gradient stops for gradient backgrounds.
  final List<double>? gradientStops;

  /// Begin alignment for gradient backgrounds.
  final Alignment gradientBegin;

  /// End alignment for gradient backgrounds.
  final Alignment gradientEnd;

  /// Opacity for dimming backgrounds.
  final double dimOpacity;

  /// Whether the highlight cutout should be transparent (hole punch effect).
  final bool holePunchTransparency;

  /// Animation curve for transitions.
  final Curve animationCurve;

  /// Default animation duration.
  final Duration animationDuration;

  /// Background color for tooltips.
  final Color? tooltipBackgroundColor;

  /// Border color for tooltips.
  final Color? tooltipBorderColor;

  /// Border width for tooltips.
  final double tooltipBorderWidth;

  /// Border radius for tooltips.
  final BorderRadius tooltipBorderRadius;

  /// Shadow color for tooltips.
  final Color tooltipShadowColor;

  /// Shadow blur radius for tooltips.
  final double tooltipShadowBlur;

  /// Shadow offset for tooltips.
  final Offset tooltipShadowOffset;

  /// Padding inside tooltips.
  final EdgeInsets tooltipPadding;

  /// Margin around tooltips.
  final EdgeInsets tooltipMargin;

  /// Size of the arrow pointing to the target.
  final double arrowSize;

  /// Color of the arrow pointing to the target.
  final Color? arrowColor;

  /// Color of the progress indicator.
  final Color? progressIndicatorColor;

  /// Background color of the progress indicator.
  final Color? progressIndicatorBackgroundColor;

  /// Height of the progress indicator.
  final double progressIndicatorHeight;

  /// Style for action buttons.
  final ButtonStyle? buttonStyle;

  /// Style for skip button.
  final ButtonStyle? skipButtonStyle;

  /// Style for next button.
  final ButtonStyle? nextButtonStyle;

  /// Style for previous button.
  final ButtonStyle? previousButtonStyle;

  /// Style for close button.
  final ButtonStyle? closeButtonStyle;

  /// Whether to support right-to-left layouts.
  final bool rtlSupport;

  /// Whether to enable accessibility announcements.
  final bool accessibilityAnnouncements;

  /// Whether to enable keyboard navigation.
  final bool keyboardNavigation;

  /// Creates a copy of this theme data with the given fields replaced.
  ///
  /// All parameters are optional and will use the current values if not provided.
  NextgenShowcaseThemeData copyWith({
    Color? backdropColor,
    double? backdropBlurSigma,
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
    // New advanced theme properties
    BackgroundType? backgroundType,
    List<double>? gradientStops,
    Alignment? gradientBegin,
    Alignment? gradientEnd,
    double? dimOpacity,
    bool? holePunchTransparency,
    Curve? animationCurve,
    Duration? animationDuration,
    Color? tooltipBackgroundColor,
    Color? tooltipBorderColor,
    double? tooltipBorderWidth,
    BorderRadius? tooltipBorderRadius,
    Color? tooltipShadowColor,
    double? tooltipShadowBlur,
    Offset? tooltipShadowOffset,
    EdgeInsets? tooltipPadding,
    EdgeInsets? tooltipMargin,
    double? arrowSize,
    Color? arrowColor,
    Color? progressIndicatorColor,
    Color? progressIndicatorBackgroundColor,
    double? progressIndicatorHeight,
    ButtonStyle? buttonStyle,
    ButtonStyle? skipButtonStyle,
    ButtonStyle? nextButtonStyle,
    ButtonStyle? previousButtonStyle,
    ButtonStyle? closeButtonStyle,
    bool? rtlSupport,
    bool? accessibilityAnnouncements,
    bool? keyboardNavigation,
  }) {
    return NextgenShowcaseThemeData(
      backdropColor: backdropColor ?? this.backdropColor,
      backdropBlurSigma: backdropBlurSigma ?? this.backdropBlurSigma,
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
      // New advanced theme properties
      backgroundType: backgroundType ?? this.backgroundType,
      gradientStops: gradientStops ?? this.gradientStops,
      gradientBegin: gradientBegin ?? this.gradientBegin,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      dimOpacity: dimOpacity ?? this.dimOpacity,
      holePunchTransparency: holePunchTransparency ?? this.holePunchTransparency,
      animationCurve: animationCurve ?? this.animationCurve,
      animationDuration: animationDuration ?? this.animationDuration,
      tooltipBackgroundColor: tooltipBackgroundColor ?? this.tooltipBackgroundColor,
      tooltipBorderColor: tooltipBorderColor ?? this.tooltipBorderColor,
      tooltipBorderWidth: tooltipBorderWidth ?? this.tooltipBorderWidth,
      tooltipBorderRadius: tooltipBorderRadius ?? this.tooltipBorderRadius,
      tooltipShadowColor: tooltipShadowColor ?? this.tooltipShadowColor,
      tooltipShadowBlur: tooltipShadowBlur ?? this.tooltipShadowBlur,
      tooltipShadowOffset: tooltipShadowOffset ?? this.tooltipShadowOffset,
      tooltipPadding: tooltipPadding ?? this.tooltipPadding,
      tooltipMargin: tooltipMargin ?? this.tooltipMargin,
      arrowSize: arrowSize ?? this.arrowSize,
      arrowColor: arrowColor ?? this.arrowColor,
      progressIndicatorColor: progressIndicatorColor ?? this.progressIndicatorColor,
      progressIndicatorBackgroundColor: progressIndicatorBackgroundColor ?? this.progressIndicatorBackgroundColor,
      progressIndicatorHeight: progressIndicatorHeight ?? this.progressIndicatorHeight,
      buttonStyle: buttonStyle ?? this.buttonStyle,
      skipButtonStyle: skipButtonStyle ?? this.skipButtonStyle,
      nextButtonStyle: nextButtonStyle ?? this.nextButtonStyle,
      previousButtonStyle: previousButtonStyle ?? this.previousButtonStyle,
      closeButtonStyle: closeButtonStyle ?? this.closeButtonStyle,
      rtlSupport: rtlSupport ?? this.rtlSupport,
      accessibilityAnnouncements: accessibilityAnnouncements ?? this.accessibilityAnnouncements,
      keyboardNavigation: keyboardNavigation ?? this.keyboardNavigation,
    );
  }

  /// Create a derived theme using ambient Material theme defaults.
  NextgenShowcaseThemeData resolvedFor(BuildContext context) {
    final ThemeData material = Theme.of(context);
    final bool isDark = material.brightness == Brightness.dark;
    final Color resolvedCard = cardColor ?? material.colorScheme.surface;

    // Enhanced gradient colors for better visual appeal
    final List<Color> resolvedGradient = gradientColors.isNotEmpty
        ? gradientColors
        : (isDark
            ? <Color>[
                const Color(0xFF667eea),
                const Color(0xFF764ba2),
                const Color(0xFFf093fb),
                const Color(0xFFf5576c)
              ]
            : <Color>[
                const Color(0xFF667eea),
                const Color(0xFF764ba2),
                const Color(0xFFf093fb),
                const Color(0xFFf5576c)
              ]);

    return copyWith(
      cardColor: resolvedCard,
      gradientColors: resolvedGradient,
      // Preserve user-configured backdrop color; do not override here
      backdropColor: backdropColor,
      backdropBlurSigma: backdropBlurSigma,
    );
  }
}
