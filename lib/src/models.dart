import 'package:flutter/material.dart';
import 'dart:ui' as ui;

typedef ShowcaseActionCallback = void Function();
typedef ShowcaseContentBuilder = Widget Function(BuildContext context);

enum ShowcaseShape { rectangle, roundedRectangle, circle, oval, stadium, diamond, custom }

class ShowcaseAction {
  const ShowcaseAction({required this.label, this.onPressed});
  final String label;
  final ShowcaseActionCallback? onPressed;
}

class ShowcaseStep {
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
  });

  final GlobalKey key;
  final String title;
  final String description;
  final ShowcaseShape shape;
  final BorderRadius borderRadius;
  final List<ShowcaseAction> actions;
  final EdgeInsets padding;
  final ShowcaseContentBuilder? contentBuilder;
  final ui.Path? customCutoutPath;
}


