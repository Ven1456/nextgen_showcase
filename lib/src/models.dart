import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Callback function type for showcase actions.
typedef ShowcaseActionCallback = void Function();

/// Builder function type for custom showcase content.
typedef ShowcaseContentBuilder = Widget Function(BuildContext context);

/// Builder for a custom cutout path based on the spotlight rect.
typedef ShowcaseCutoutBuilder = ui.Path Function(ui.Rect rect);

/// Built-in card transition styles.
enum CardTransition {
  fade,
  zoom,
  slideUp,
  elasticIn,
}

/// Available shapes for the spotlight effect.
enum ShowcaseShape {
  /// Rectangular spotlight with sharp corners.
  rectangle,

  /// Rectangular spotlight with rounded corners.
  roundedRectangle,

  /// Circular spotlight.
  circle,

  /// Oval spotlight.
  oval,

  /// Stadium-shaped spotlight (pill shape).
  stadium,

  /// Diamond-shaped spotlight.
  diamond,

  /// Custom shape defined by a path.
  custom
}

/// Decorator allows wrapping the overlay stack to inject custom effects/widgets.
typedef ShowcaseDecorator = Widget Function(
  BuildContext context,
  ShowcaseStep step,
  Rect spotlightRect,
  Widget child,
);

/// Builder for additional overlay widgets layered above the painter and below the card.
typedef ShowcaseOverlayWidgetBuilder = List<Widget> Function(
  BuildContext context,
  ShowcaseStep step,
  Rect spotlightRect,
);

/// Represents an action button in a showcase step.
///
/// Actions are displayed as buttons in the showcase card and allow
/// users to perform custom actions during the showcase.
class ShowcaseAction {
  /// Creates a showcase action.
  ///
  /// The [label] parameter is required and represents the button text.
  /// The [onPressed] callback is optional and defines the action to perform.
  const ShowcaseAction({required this.label, this.onPressed});

  /// The text label displayed on the action button.
  final String label;

  /// The callback function to execute when the action is pressed.
  final ShowcaseActionCallback? onPressed;
}

/// Represents a single step in a showcase.
///
/// Each step defines what should be highlighted and what information
/// should be displayed to the user.
class ShowcaseStep {
  /// Creates a showcase step.
  ///
  /// The [key], [title], and [description] parameters are required.
  /// The [key] must be attached to the widget that should be highlighted.
  const ShowcaseStep({
    required this.key,
    required this.title,
    required this.description,
    this.shape = ShowcaseShape.roundedRectangle,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.actions = const <ShowcaseAction>[],
    this.padding = const EdgeInsets.all(8),
    this.contentBuilder,
    this.customCutoutPath,
    this.customCutoutBuilder,
    this.testId,
  });

  /// The global key attached to the target widget.
  final GlobalKey key;

  /// The title displayed in the showcase card.
  final String title;

  /// The description text displayed in the showcase card.
  final String description;

  /// The shape of the spotlight effect.
  final ShowcaseShape shape;

  /// The border radius for rounded shapes.
  final BorderRadius borderRadius;

  /// List of action buttons for this step.
  final List<ShowcaseAction> actions;

  /// Padding around the spotlight area.
  final EdgeInsets padding;

  /// Optional custom content builder for the showcase card.
  ///
  /// If provided, this will be used instead of the default card
  /// with title and description.
  final ShowcaseContentBuilder? contentBuilder;

  /// Custom path for the spotlight cutout when using [ShowcaseShape.custom].
  final ui.Path? customCutoutPath;

  /// Custom path builder for the spotlight cutout based on the spotlight rectangle.
  ///
  /// When provided and [shape] is [ShowcaseShape.custom], this will be used to
  /// generate the cutout path. It takes the padded spotlight rectangle.
  final ShowcaseCutoutBuilder? customCutoutBuilder;

  /// Optional test identifier to facilitate widget tests and semantics keys.
  final String? testId;
}
