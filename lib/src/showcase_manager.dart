import 'package:flutter/material.dart';
import 'controller.dart';

/// Global showcase manager to ensure only one showcase is active at a time.
class ShowcaseManager {
  static final ShowcaseManager _instance = ShowcaseManager._internal();
  factory ShowcaseManager() => _instance;
  ShowcaseManager._internal();

  NextgenShowcaseController? _activeController;

  /// Gets the currently active controller, if any.
  NextgenShowcaseController? get activeController => _activeController;

  /// Whether there's currently an active showcase.
  bool get hasActiveShowcase => _activeController != null;

  /// Starts a new showcase, dismissing any existing one first.
  void startShowcase(
      NextgenShowcaseController controller, BuildContext context) {
    // Dismiss any existing showcase
    if (_activeController != null && _activeController!.isShowing) {
      _activeController!.dismiss();
    }

    _activeController = controller;
    controller.start(context);
  }

  /// Dismisses the currently active showcase.
  void dismissActive() {
    if (_activeController != null && _activeController!.isShowing) {
      _activeController!.dismiss();
    }
    _activeController = null;
  }

  /// Clears the active controller reference (called when controller is disposed).
  void clearActive() {
    _activeController = null;
  }
}

/// Extension on NextgenShowcaseController to integrate with the global manager.
extension ShowcaseControllerExtension on NextgenShowcaseController {
  /// Starts this showcase using the global manager (ensures only one is active).
  void startManaged(BuildContext context) {
    ShowcaseManager().startShowcase(this, context);
  }
}
