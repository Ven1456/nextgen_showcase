import 'package:flutter/material.dart';

import 'config.dart';
import 'controller.dart';
import 'models.dart';
import 'nextgen_showcase.dart';

/// Fluent builder API to configure and mount a Nextgen Showcase with minimal boilerplate.
class ShowcaseBuilder {
  ShowcaseBuilder._(this._controller);

  /// Create a new builder with an optional existing controller.
  factory ShowcaseBuilder({NextgenShowcaseController? controller}) {
    return ShowcaseBuilder._(controller ?? NextgenShowcaseController());
  }

  final NextgenShowcaseController _controller;
  final List<ShowcaseStep> _steps = <ShowcaseStep>[];
  ShowcaseConfig? _config;
  int _initialIndex = 0;
  bool _autoStart = true;

  /// Set steps in bulk.
  ShowcaseBuilder steps(List<ShowcaseStep> steps) {
    _steps
      ..clear()
      ..addAll(steps);
    return this;
  }

  /// Add a single step.
  ShowcaseBuilder addStep(ShowcaseStep step) {
    _steps.add(step);
    return this;
  }

  /// Provide configuration.
  ShowcaseBuilder config(ShowcaseConfig config) {
    _config = config;
    return this;
  }

  /// Choose initial step index.
  ShowcaseBuilder initialIndex(int index) {
    _initialIndex = index;
    return this;
  }

  /// Auto-start showcase after first frame.
  ShowcaseBuilder autoStart([bool value = true]) {
    _autoStart = value;
    return this;
  }

  /// Lifecycle callbacks.
  ShowcaseBuilder onStepStart(ValueChanged<int> callback) {
    _controller.onStepStart = callback;
    return this;
  }

  ShowcaseBuilder onStepComplete(ValueChanged<int> callback) {
    _controller.onStepComplete = callback;
    return this;
  }

  ShowcaseBuilder onShowcaseEnd(VoidCallback callback) {
    _controller.onShowcaseEnd = callback;
    return this;
  }

  /// Access the underlying controller (e.g., to call next/previous).
  NextgenShowcaseController get controller => _controller;

  /// Wrap your app with a configured NextgenShowcase.
  Widget wrap({Key? key, required Widget child}) {
    return NextgenShowcase(
      key: key,
      controller: _controller,
      steps: List<ShowcaseStep>.unmodifiable(_steps),
      config: _config,
      autoStart: _autoStart,
      initialIndex: _initialIndex,
      child: child,
    );
  }

  /// Convenience to update steps on the controller without wrapping.
  /// Useful if you manage theming separately and start imperatively.
  void applyToController() {
    _controller.setSteps(List<ShowcaseStep>.unmodifiable(_steps));
    _controller.setConfig(_config);
  }
}
