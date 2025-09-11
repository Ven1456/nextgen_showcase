import 'package:flutter/material.dart';

class NextgenShowcaseController {
  NextgenShowcaseController();

  OverlayEntry? _activeEntry;

  bool get isShowing => _activeEntry != null;

  void show({
    required BuildContext context,
    required GlobalKey targetKey,
    required String title,
    required String description,
  }) {
    if (isShowing) {
      return;
    }

    final RenderBox? targetRenderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetRenderBox == null) {
      return;
    }

    final Offset targetOffset = targetRenderBox.localToGlobal(Offset.zero);
    final Size targetSize = targetRenderBox.size;

    _activeEntry = OverlayEntry(
      builder: (BuildContext context) {
        return _ShowcaseOverlay(
          onDismiss: hide,
          targetOffset: targetOffset,
          targetSize: targetSize,
          title: title,
          description: description,
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_activeEntry!);
  }

  void hide() {
    _activeEntry?.remove();
    _activeEntry = null;
  }
}

class _ShowcaseOverlay extends StatelessWidget {
  const _ShowcaseOverlay({
    required this.onDismiss,
    required this.targetOffset,
    required this.targetSize,
    required this.title,
    required this.description,
  });

  final VoidCallback onDismiss;
  final Offset targetOffset;
  final Size targetSize;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size screenSize = MediaQuery.of(context).size;

    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: onDismiss,
          child: Container(
            width: screenSize.width,
            height: screenSize.height,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        Positioned(
          left: targetOffset.dx - 8,
          top: targetOffset.dy - 8,
          child: IgnorePointer(
            child: Container(
              width: targetSize.width + 16,
              height: targetSize.height + 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: (targetOffset.dy + targetSize.height + 16)
              .clamp(16.0, screenSize.height - 200),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onDismiss,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


