import 'package:flutter/material.dart';
import 'package:nextgen_showcase/nextgen_showcase.dart';

/// Unified configuration for Nextgen Showcase with sensible defaults and full control.
///
/// This class allows you to customize the appearance and behavior of the showcase.
/// All parameters are optional and will use sensible defaults if not provided.
///
/// Example usage:
/// ```dart
/// const config = ShowcaseConfig(
///   backdropColor: Colors.black54,
///   cardColor: Colors.white,
///   stunMode: true,
///   gradientColors: [Colors.blue, Colors.purple],
/// );
/// ```
class ShowcaseConfig {
  /// Creates a showcase configuration.
  ///
  /// All parameters are optional and will use default values if not provided.
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
    this.previousLabel,
    this.nextLabel,
    this.closeLabel,
    this.persistenceKey,
    this.enablePersistence,
    this.cardTransition,
    this.cardTransitionDurationMs,
    this.waitForAsyncMs,
    this.retryMissingTargetMax,
    this.showSkipButton,
    this.decorators,
    this.overlayWidgetsBuilder,
  });

  /// Visual theme options

  /// The color of the backdrop overlay.
  final Color? backdropColor;

  /// The background color of the showcase card.
  final Color? cardColor;

  /// The text style for step titles.
  final TextStyle? titleStyle;

  /// The text style for step descriptions.
  final TextStyle? descriptionStyle;

  /// The color of the spotlight shadow/glow effect.
  final Color? spotlightShadowColor;

  /// The blur radius of the spotlight shadow/glow effect.
  final double? spotlightShadowBlur;

  /// Whether to enable "stun mode" with glass morphism and gradient effects.
  final bool? stunMode;

  /// Colors for the animated gradient effect in stun mode.
  final List<Color>? gradientColors;

  /// Duration of the gradient animation in milliseconds.
  final int? gradientAnimationMs;

  /// Blur sigma for the glass morphism effect.
  final double? glassBlurSigma;

  /// Opacity of the showcase card in stun mode.
  final double? cardOpacity;

  /// Delta value for the glow pulse animation.
  final double? glowPulseDelta;

  /// Step defaults (can be overridden per step)

  /// Default shape for all steps (can be overridden per step).
  final dynamic
      defaultShape; // late-bound to ShowcaseShape to avoid import cycle

  /// Default border radius for all steps.
  final BorderRadius? defaultBorderRadius;

  /// Default padding around the spotlight area for all steps.
  final EdgeInsets? defaultPadding;

  /// Accessibility and i18n labels for default controls
  final String? previousLabel;
  final String? nextLabel;
  final String? closeLabel;

  /// Persistence key namespace; when set, we store completion flags.
  final String? persistenceKey;

  /// Enable persistence (defaults to true if persistenceKey provided).
  final bool? enablePersistence;

  /// Animation for the info card (fade, zoom, slide, elastic).
  final CardTransition? cardTransition;

  /// Duration for card transition.
  final int? cardTransitionDurationMs;

  /// Async handling
  /// Wait this long before checking target again after a miss.
  final int? waitForAsyncMs;

  /// Max retries if target is not yet built.
  final int? retryMissingTargetMax;

  /// Show Skip button on the default card.
  final bool? showSkipButton;

  /// Optional list of decorators to wrap the overlay stack with custom widgets/effects.
  final List<ShowcaseDecorator>? decorators;

  /// Additional overlay widgets layered above painter and below the card.
  final ShowcaseOverlayWidgetBuilder? overlayWidgetsBuilder;
}
