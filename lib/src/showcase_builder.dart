import 'package:flutter/material.dart';
import 'models.dart';
import 'controller.dart';
import 'config.dart';

/// A simplified builder for creating showcase flows with minimal code.
///
/// This class provides a fluent API for building showcase steps and configurations
/// with sensible defaults, reducing the complexity for end-users.
class ShowcaseFlowBuilder {
  ShowcaseFlowBuilder._();

  final List<ShowcaseStep> _steps = [];
  ShowcaseConfig? _config;

  /// Creates a new showcase flow builder instance.
  static ShowcaseFlowBuilder create() => ShowcaseFlowBuilder._();

  /// Adds a step to highlight a widget with the given key.
  ///
  /// The [key] must be attached to the widget you want to highlight.
  /// The [title] and [description] are displayed in the showcase card.
  ShowcaseFlowBuilder addStep({
    required GlobalKey key,
    required String title,
    required String description,
    ShowcaseShape shape = ShowcaseShape.roundedRectangle,
    BorderRadius? borderRadius,
    List<ShowcaseAction> actions = const [],
    EdgeInsets? padding,
    ShowcaseContentBuilder? contentBuilder,
    String? testId,
  }) {
    _steps.add(ShowcaseStep(
      key: key,
      title: title,
      description: description,
      shape: shape,
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(12)),
      actions: actions,
      padding: padding ?? const EdgeInsets.all(8),
      contentBuilder: contentBuilder,
      testId: testId,
    ));
    return this;
  }

  /// Adds a step with a circular spotlight.
  ShowcaseFlowBuilder addCircularStep({
    required GlobalKey key,
    required String title,
    required String description,
    List<ShowcaseAction> actions = const [],
    EdgeInsets? padding,
    ShowcaseContentBuilder? contentBuilder,
    String? testId,
  }) {
    return addStep(
      key: key,
      title: title,
      description: description,
      shape: ShowcaseShape.circle,
      actions: actions,
      padding: padding,
      contentBuilder: contentBuilder,
      testId: testId,
    );
  }

  /// Adds a step with a rectangular spotlight.
  ShowcaseFlowBuilder addRectangularStep({
    required GlobalKey key,
    required String title,
    required String description,
    BorderRadius? borderRadius,
    List<ShowcaseAction> actions = const [],
    EdgeInsets? padding,
    ShowcaseContentBuilder? contentBuilder,
    String? testId,
  }) {
    return addStep(
      key: key,
      title: title,
      description: description,
      shape: ShowcaseShape.roundedRectangle,
      borderRadius: borderRadius,
      actions: actions,
      padding: padding,
      contentBuilder: contentBuilder,
      testId: testId,
    );
  }

  /// Configures the showcase with the given configuration.
  ShowcaseFlowBuilder withConfig(ShowcaseConfig config) {
    _config = config;
    return this;
  }

  /// Enables stun mode with glass morphism and gradient effects.
  ShowcaseFlowBuilder enableStunMode({
    List<Color>? gradientColors,
    int? gradientAnimationMs,
    double? glassBlurSigma,
    double? cardOpacity,
  }) {
    _config = ShowcaseConfig(
      stunMode: true,
      gradientColors: gradientColors,
      gradientAnimationMs: gradientAnimationMs,
      glassBlurSigma: glassBlurSigma,
      cardOpacity: cardOpacity,
    );
    return this;
  }

  /// Sets the card transition animation.
  ShowcaseFlowBuilder withTransition(
    CardTransition transition, {
    int? durationMs,
  }) {
    _config = ShowcaseConfig(
      cardTransition: transition,
      cardTransitionDurationMs: durationMs ?? 320,
    );
    return this;
  }

  /// Sets custom colors for the showcase.
  ShowcaseFlowBuilder withColors({
    Color? backdropColor,
    Color? cardColor,
    Color? spotlightShadowColor,
    double? spotlightShadowBlur,
  }) {
    _config = ShowcaseConfig(
      backdropColor: backdropColor,
      cardColor: cardColor,
      spotlightShadowColor: spotlightShadowColor,
      spotlightShadowBlur: spotlightShadowBlur,
    );
    return this;
  }

  /// Builds the showcase controller with all configured steps and settings.
  NextgenShowcaseController build() {
    final controller = NextgenShowcaseController(config: _config);
    controller.setSteps(_steps);
    return controller;
  }

  /// Builds and starts the showcase immediately.
  void start(BuildContext context, {int initialIndex = 0}) {
    final controller = build();
    controller.start(context, initialIndex: initialIndex);
  }
}

/// Extension methods for easier showcase creation.
extension ShowcaseExtensions on GlobalKey {
  /// Creates a simple showcase step for this key.
  ShowcaseStep toShowcaseStep({
    required String title,
    required String description,
    ShowcaseShape shape = ShowcaseShape.roundedRectangle,
    BorderRadius? borderRadius,
    List<ShowcaseAction> actions = const [],
    EdgeInsets? padding,
    ShowcaseContentBuilder? contentBuilder,
    String? testId,
  }) {
    return ShowcaseStep(
      key: this,
      title: title,
      description: description,
      shape: shape,
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(12)),
      actions: actions,
      padding: padding ?? const EdgeInsets.all(8),
      contentBuilder: contentBuilder,
      testId: testId,
    );
  }

  /// Creates a circular showcase step for this key.
  ShowcaseStep toCircularShowcaseStep({
    required String title,
    required String description,
    List<ShowcaseAction> actions = const [],
    EdgeInsets? padding,
    ShowcaseContentBuilder? contentBuilder,
    String? testId,
  }) {
    return toShowcaseStep(
      title: title,
      description: description,
      shape: ShowcaseShape.circle,
      actions: actions,
      padding: padding,
      contentBuilder: contentBuilder,
      testId: testId,
    );
  }
}

/// Predefined showcase configurations for common use cases.
class ShowcasePresets {
  /// A modern configuration with glass morphism effects.
  static ShowcaseConfig modern() => ShowcaseConfig(
        stunMode: true,
        cardTransition: CardTransition.elasticIn,
        cardTransitionDurationMs: 400,
        gradientColors: const [
          Color(0xFF667eea),
          Color(0xFF764ba2),
          Color(0xFFf093fb),
          Color(0xFFf5576c),
        ],
        glassBlurSigma: 15,
        cardOpacity: 0.9,
      );

  /// A minimal configuration with subtle effects.
  static ShowcaseConfig minimal() => ShowcaseConfig(
        backdropColor: const Color(0xCC000000),
        cardTransition: CardTransition.fade,
        cardTransitionDurationMs: 200,
        spotlightShadowBlur: 16,
      );

  /// A playful configuration with bouncy animations.
  static ShowcaseConfig playful() => ShowcaseConfig(
        cardTransition: CardTransition.bounceIn,
        cardTransitionDurationMs: 600,
        spotlightShadowBlur: 32,
        glowPulseDelta: 15,
      );

  /// A professional configuration for business apps.
  static ShowcaseConfig professional() => ShowcaseConfig(
        backdropColor: const Color(0xE6000000),
        cardColor: Colors.white,
        cardTransition: CardTransition.slideUp,
        cardTransitionDurationMs: 300,
        spotlightShadowBlur: 20,
      );
}
