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
  slideFromRight,
  bounceIn,
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

  /// Polygon-shaped spotlight with configurable sides.
  polygon,

  /// Star-shaped spotlight with configurable points.
  star,

  /// Custom shape defined by a path.
  custom
}

/// Animation types for highlight shapes.
enum HighlightAnimation {
  /// No animation.
  none,

  /// Scale in/out animation.
  scale,

  /// Pulsing animation.
  pulse,

  /// Glowing animation.
  glow,

  /// Bounce animation.
  bounce,

  /// Elastic animation.
  elastic,

  /// Custom animation.
  custom
}

/// Tooltip placement options.
enum TooltipPlacement {
  /// Automatically choose the best position.
  auto,

  /// Place above the target.
  top,

  /// Place below the target.
  bottom,

  /// Place to the left of the target.
  left,

  /// Place to the right of the target.
  right,

  /// Place at the top-left.
  topLeft,

  /// Place at the top-right.
  topRight,

  /// Place at the bottom-left.
  bottomLeft,

  /// Place at the bottom-right.
  bottomRight
}

/// Background types for the showcase overlay.
enum BackgroundType {
  /// Solid color background.
  solid,

  /// Gradient background.
  gradient,

  /// Blur effect background.
  blur,

  /// Dimming with transparency.
  dim,

  /// Glass morphism effect.
  glass,

  /// Custom background.
  custom
}

/// Interaction modes for the showcase.
enum InteractionMode {
  /// Allow interaction with highlighted widget.
  allowHighlight,

  /// Block interaction with highlighted widget.
  blockHighlight,

  /// Allow interaction outside showcase area.
  allowOutside,

  /// Block interaction outside showcase area.
  blockOutside
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
    // New advanced features
    this.highlightAnimation = HighlightAnimation.scale,
    this.animationDuration = const Duration(milliseconds: 300),
    this.tooltipPlacement = TooltipPlacement.auto,
    this.tooltipShape = TooltipShape.roundedRectangle,
    this.tooltipArrow = true,
    this.richContent,
    this.icon,
    this.image,
    this.heroAnimation = false,
    this.interactionMode = InteractionMode.blockHighlight,
    this.allowTapHighlight = false,
    this.allowTapOutside = false,
    this.gestureSupport = true,
    this.autoAdvance = false,
    this.autoAdvanceDelay = const Duration(seconds: 3),
    this.progressIndicator = false,
    this.persistent = false,
    this.polygonSides = 6,
    this.starPoints = 5,
    this.starInnerRadius = 0.4,
    this.customAnimation,
    this.onStart,
    this.onNext,
    this.onSkip,
    this.onFinish,
    this.onTapHighlight,
    this.onTapOutside,
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

  // Advanced Features

  /// Animation type for the highlight effect.
  final HighlightAnimation highlightAnimation;

  /// Duration of the highlight animation.
  final Duration animationDuration;

  /// Placement of the tooltip relative to the target.
  final TooltipPlacement tooltipPlacement;

  /// Shape of the tooltip.
  final TooltipShape tooltipShape;

  /// Whether to show an arrow pointing to the target.
  final bool tooltipArrow;

  /// Rich content for the tooltip (supports HTML-like formatting).
  final String? richContent;

  /// Optional icon to display in the tooltip.
  final IconData? icon;

  /// Optional image to display in the tooltip.
  final String? image;

  /// Whether to use hero animation for the tooltip.
  final bool heroAnimation;

  /// Interaction mode for this step.
  final InteractionMode interactionMode;

  /// Whether to allow tapping on the highlighted widget.
  final bool allowTapHighlight;

  /// Whether to allow tapping outside the showcase area.
  final bool allowTapOutside;

  /// Whether to support gesture navigation (swipe, etc.).
  final bool gestureSupport;

  /// Whether to automatically advance to the next step.
  final bool autoAdvance;

  /// Delay before auto-advancing to the next step.
  final Duration autoAdvanceDelay;

  /// Whether to show a progress indicator.
  final bool progressIndicator;

  /// Whether the tooltip should persist until manually dismissed.
  final bool persistent;

  /// Number of sides for polygon shape.
  final int polygonSides;

  /// Number of points for star shape.
  final int starPoints;

  /// Inner radius ratio for star shape (0.0 to 1.0).
  final double starInnerRadius;

  /// Custom animation for the highlight effect.
  final Animation<double>? customAnimation;

  // Event callbacks
  final VoidCallback? onStart;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final VoidCallback? onFinish;
  final VoidCallback? onTapHighlight;
  final VoidCallback? onTapOutside;
}

/// Tooltip shape options.
enum TooltipShape {
  /// Rounded rectangle tooltip.
  roundedRectangle,

  /// Bubble tooltip with arrow.
  bubble,

  /// Completely custom tooltip shape.
  custom
}
