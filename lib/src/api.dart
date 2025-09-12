import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'config.dart';
import 'controller.dart';
import 'models.dart';

/// Simplest way to run a showcase.
///
/// Example:
/// ```dart
/// final GlobalKey btnKey = GlobalKey();
/// await showShowcase(
///   context,
///   steps: <ShowcaseStep>[
///     ShowcaseStep(key: btnKey, title: 'Hello', description: 'Tap here'),
///   ],
///   config: const ShowcaseConfig(stunMode: true),
/// );
/// ```
Future<NextgenShowcaseController> showShowcase(
  BuildContext context, {
  required List<ShowcaseStep> steps,
  ShowcaseConfig? config,
  int initialIndex = 0,
  NextgenShowcaseController? controller,
}) async {
  final NextgenShowcaseController c = controller ?? NextgenShowcaseController();
  c.setConfig(config);
  c.setSteps(steps);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    c.start(context, initialIndex: initialIndex);
  });
  return c;
}

/// Super-simple helper for spotlighting a single widget.
///
/// Example:
/// ```dart
/// await showSpotlight(
///   context,
///   key: myButtonKey,
///   title: 'Tap here',
///   description: 'This starts your journey',
///   shape: ShowcaseShape.circle,
/// );
/// ```
Future<NextgenShowcaseController> showSpotlight(
  BuildContext context, {
  required GlobalKey key,
  required String title,
  required String description,
  ShowcaseShape shape = ShowcaseShape.roundedRectangle,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
  EdgeInsets padding = const EdgeInsets.all(8),
  ShowcaseConfig? config,
  ShowcaseContentBuilder? contentBuilder,
  ui.Path? customCutoutPath,
  ShowcaseCutoutBuilder? customCutoutBuilder,
  String? testId,
  NextgenShowcaseController? controller,
}) async {
  final ShowcaseStep step = ShowcaseStep(
    key: key,
    title: title,
    description: description,
    shape: shape,
    borderRadius: borderRadius,
    padding: padding,
    contentBuilder: contentBuilder,
    customCutoutPath: customCutoutPath,
    customCutoutBuilder: customCutoutBuilder,
    testId: testId,
  );
  return showShowcase(
    context,
    steps: <ShowcaseStep>[step],
    config: config,
    controller: controller,
  );
}

