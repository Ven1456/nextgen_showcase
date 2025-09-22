import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

/// Advanced tooltip widget with rich content, animations, and adaptive positioning.
class AdvancedTooltip extends StatefulWidget {
  /// Creates an advanced tooltip.
  const AdvancedTooltip({
    super.key,
    required this.step,
    required this.spotlightRect,
    required this.screenSize,
    required this.theme,
    this.onNext,
    this.onPrevious,
    this.onSkip,
    this.onClose,
    this.onTapHighlight,
    this.onTapOutside,
  });

  /// The showcase step configuration.
  final ShowcaseStep step;

  /// The rectangle of the spotlight area.
  final Rect spotlightRect;

  /// The size of the screen.
  final Size screenSize;

  /// The theme for the tooltip.
  final NextgenShowcaseThemeData theme;

  /// Callback for next action.
  final VoidCallback? onNext;

  /// Callback for previous action.
  final VoidCallback? onPrevious;

  /// Callback for skip action.
  final VoidCallback? onSkip;

  /// Callback for close action.
  final VoidCallback? onClose;

  /// Callback for tap on highlight.
  final VoidCallback? onTapHighlight;

  /// Callback for tap outside.
  final VoidCallback? onTapOutside;

  @override
  State<AdvancedTooltip> createState() => _AdvancedTooltipState();
}

class _AdvancedTooltipState extends State<AdvancedTooltip>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _heroAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  TooltipPosition? _calculatedPosition;
  bool _isPositioned = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePosition();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heroAnimationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: widget.step.animationDuration,
      vsync: this,
    );

    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: _getSlideBeginOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  Offset _getSlideBeginOffset() {
    switch (widget.step.tooltipPlacement) {
      case TooltipPlacement.top:
      case TooltipPlacement.topLeft:
      case TooltipPlacement.topRight:
        return const Offset(0, -1);
      case TooltipPlacement.bottom:
      case TooltipPlacement.bottomLeft:
      case TooltipPlacement.bottomRight:
        return const Offset(0, 1);
      case TooltipPlacement.left:
        return const Offset(-1, 0);
      case TooltipPlacement.right:
        return const Offset(1, 0);
      case TooltipPlacement.auto:
        return const Offset(0, -1);
    }
  }

  void _calculatePosition() {
    if (_isPositioned) return;

    final TooltipPosition position = _calculateOptimalPosition();
    setState(() {
      _calculatedPosition = position;
      _isPositioned = true;
    });
  }

  TooltipPosition _calculateOptimalPosition() {
    final Rect rect = widget.spotlightRect;
    final Size screenSize = widget.screenSize;
    final EdgeInsets margin = widget.theme.tooltipMargin;
    const double minDistance = 16.0;

    // Calculate available space in each direction
    final double spaceTop = rect.top - margin.top;
    final double spaceBottom = screenSize.height - rect.bottom - margin.bottom;
    final double spaceLeft = rect.left - margin.left;
    final double spaceRight = screenSize.width - rect.right - margin.right;

    // Determine the best placement
    TooltipPlacement placement = widget.step.tooltipPlacement;
    
    if (placement == TooltipPlacement.auto) {
      // Auto-select the best position
      if (spaceTop > spaceBottom && spaceTop > minDistance) {
        placement = TooltipPlacement.top;
      } else if (spaceBottom > minDistance) {
        placement = TooltipPlacement.bottom;
      } else if (spaceLeft > spaceRight && spaceLeft > minDistance) {
        placement = TooltipPlacement.left;
      } else if (spaceRight > minDistance) {
        placement = TooltipPlacement.right;
      } else {
        placement = TooltipPlacement.top; // Fallback
      }
    }

    return _calculatePositionForPlacement(placement, rect, screenSize);
  }

  TooltipPosition _calculatePositionForPlacement(
    TooltipPlacement placement,
    Rect rect,
    Size screenSize,
  ) {
    final EdgeInsets margin = widget.theme.tooltipMargin;
    const double arrowSize = 8.0;
    const double spacing = 12.0;

    switch (placement) {
      case TooltipPlacement.top:
        return TooltipPosition(
          placement: placement,
          offset: Offset(
            rect.center.dx - 150, // Approximate tooltip width / 2
            rect.top - spacing - arrowSize,
          ),
          arrowOffset: Offset(rect.center.dx, rect.top - arrowSize),
          arrowDirection: ArrowDirection.down,
        );

      case TooltipPlacement.bottom:
        return TooltipPosition(
          placement: placement,
          offset: Offset(
            rect.center.dx - 150,
            rect.bottom + spacing + arrowSize,
          ),
          arrowOffset: Offset(rect.center.dx, rect.bottom + arrowSize),
          arrowDirection: ArrowDirection.up,
        );

      case TooltipPlacement.left:
        return TooltipPosition(
          placement: placement,
          offset: Offset(
            rect.left - spacing - arrowSize - 300, // Approximate tooltip width
            rect.center.dy - 100, // Approximate tooltip height / 2
          ),
          arrowOffset: Offset(rect.left - arrowSize, rect.center.dy),
          arrowDirection: ArrowDirection.right,
        );

      case TooltipPlacement.right:
        return TooltipPosition(
          placement: placement,
          offset: Offset(
            rect.right + spacing + arrowSize,
            rect.center.dy - 100,
          ),
          arrowOffset: Offset(rect.right + arrowSize, rect.center.dy),
          arrowDirection: ArrowDirection.left,
        );

      case TooltipPlacement.topLeft:
        return TooltipPosition(
          placement: placement,
          offset: Offset(
            rect.left,
            rect.top - spacing - arrowSize,
          ),
          arrowOffset: Offset(rect.left + 20, rect.top - arrowSize),
          arrowDirection: ArrowDirection.down,
        );

      case TooltipPlacement.topRight:
        return TooltipPosition(
          placement: placement,
          offset: Offset(
            rect.right - 300,
            rect.top - spacing - arrowSize,
          ),
          arrowOffset: Offset(rect.right - 20, rect.top - arrowSize),
          arrowDirection: ArrowDirection.down,
        );

      case TooltipPlacement.bottomLeft:
        return TooltipPosition(
          placement: placement,
          offset: Offset(
            rect.left,
            rect.bottom + spacing + arrowSize,
          ),
          arrowOffset: Offset(rect.left + 20, rect.bottom + arrowSize),
          arrowDirection: ArrowDirection.up,
        );

      case TooltipPlacement.bottomRight:
        return TooltipPosition(
          placement: placement,
          offset: Offset(
            rect.right - 300,
            rect.bottom + spacing + arrowSize,
          ),
          arrowOffset: Offset(rect.right - 20, rect.bottom + arrowSize),
          arrowDirection: ArrowDirection.up,
        );

      case TooltipPlacement.auto:
        return _calculatePositionForPlacement(TooltipPlacement.top, rect, screenSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPositioned || _calculatedPosition == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: _calculatedPosition!.offset.dx,
      top: _calculatedPosition!.offset.dy,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildTooltipContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTooltipContent() {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 300,
          minWidth: 200,
        ),
        child: _buildTooltipShape(),
      ),
    );
  }

  Widget _buildTooltipShape() {
    switch (widget.step.tooltipShape) {
      case TooltipShape.roundedRectangle:
        return _buildRoundedRectangleTooltip();
      case TooltipShape.bubble:
        return _buildBubbleTooltip();
      case TooltipShape.custom:
        return _buildCustomTooltip();
    }
  }

  Widget _buildRoundedRectangleTooltip() {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.tooltipBackgroundColor ?? 
                Theme.of(context).colorScheme.surface,
        borderRadius: widget.theme.tooltipBorderRadius,
        border: widget.theme.tooltipBorderColor != null
            ? Border.all(
                color: widget.theme.tooltipBorderColor!,
                width: widget.theme.tooltipBorderWidth,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: widget.theme.tooltipShadowColor,
            blurRadius: widget.theme.tooltipShadowBlur,
            offset: widget.theme.tooltipShadowOffset,
          ),
        ],
      ),
      padding: widget.theme.tooltipPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTooltipBody(),
          if (widget.step.tooltipArrow) _buildArrow(),
        ],
      ),
    );
  }

  Widget _buildBubbleTooltip() {
    return CustomPaint(
      painter: BubbleTooltipPainter(
        backgroundColor: widget.theme.tooltipBackgroundColor ?? 
                        Theme.of(context).colorScheme.surface,
        borderColor: widget.theme.tooltipBorderColor,
        borderWidth: widget.theme.tooltipBorderWidth,
        shadowColor: widget.theme.tooltipShadowColor,
        shadowBlur: widget.theme.tooltipShadowBlur,
        shadowOffset: widget.theme.tooltipShadowOffset,
        arrowDirection: _calculatedPosition!.arrowDirection,
        arrowSize: widget.theme.arrowSize,
        borderRadius: widget.theme.tooltipBorderRadius,
      ),
      child: Container(
        padding: widget.theme.tooltipPadding,
        child: _buildTooltipBody(),
      ),
    );
  }

  Widget _buildCustomTooltip() {
    // For custom tooltips, developers can provide their own content builder
    if (widget.step.contentBuilder != null) {
      return widget.step.contentBuilder!(context);
    }
    return _buildRoundedRectangleTooltip();
  }

  Widget _buildTooltipBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.step.icon != null) ...[
          Icon(
            widget.step.icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
        ],
        if (widget.step.image != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              widget.step.image!,
              width: 200,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          widget.step.title,
          style: widget.theme.titleStyle ??
                 Theme.of(context).textTheme.titleMedium?.copyWith(
                   fontWeight: FontWeight.bold,
                 ),
        ),
        const SizedBox(height: 4),
        if (widget.step.richContent != null)
          _buildRichContent()
        else
          Text(
            widget.step.description,
            style: widget.theme.descriptionStyle ??
                   Theme.of(context).textTheme.bodyMedium,
          ),
        if (widget.step.actions.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildActionButtons(),
        ],
        if (widget.step.progressIndicator) ...[
          const SizedBox(height: 12),
          _buildProgressIndicator(),
        ],
      ],
    );
  }

  Widget _buildRichContent() {
    // Simple rich content parser for basic HTML-like formatting
    final String content = widget.step.richContent!;
    final List<TextSpan> spans = [];
    
    // This is a simplified parser - in a real implementation,
    // you might want to use a proper HTML parser
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final RegExp italicRegex = RegExp(r'\*(.*?)\*');
    
    String remaining = content;
    int lastIndex = 0;
    
    while (remaining.isNotEmpty) {
      final Match? boldMatch = boldRegex.firstMatch(remaining);
      final Match? italicMatch = italicRegex.firstMatch(remaining);
      
      Match? nextMatch;
      if (boldMatch != null && italicMatch != null) {
        nextMatch = boldMatch.start < italicMatch.start ? boldMatch : italicMatch;
      } else if (boldMatch != null) {
        nextMatch = boldMatch;
      } else if (italicMatch != null) {
        nextMatch = italicMatch;
      }
      
      if (nextMatch != null) {
        // Add text before the match
        if (nextMatch.start > 0) {
          spans.add(TextSpan(
            text: remaining.substring(0, nextMatch.start),
            style: widget.theme.descriptionStyle ?? 
                   Theme.of(context).textTheme.bodyMedium,
          ));
        }
        
        // Add the formatted text
        final bool isBold = nextMatch == boldMatch;
        spans.add(TextSpan(
          text: nextMatch.group(1),
          style: (widget.theme.descriptionStyle ?? 
                  Theme.of(context).textTheme.bodyMedium)?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: isBold ? FontStyle.normal : FontStyle.italic,
          ),
        ));
        
        remaining = remaining.substring(nextMatch.end);
      } else {
        // Add remaining text
        spans.add(TextSpan(
          text: remaining,
          style: widget.theme.descriptionStyle ?? 
                 Theme.of(context).textTheme.bodyMedium,
        ));
        break;
      }
    }
    
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ...widget.step.actions.map((action) => ElevatedButton(
          onPressed: action.onPressed,
          style: widget.theme.buttonStyle,
          child: Text(action.label),
        )),
        if (widget.step.actions.length > 1) ...[
          if (widget.onPrevious != null)
            TextButton(
              onPressed: widget.onPrevious,
              style: widget.theme.previousButtonStyle,
              child: const Text('Previous'),
            ),
          if (widget.onNext != null)
            ElevatedButton(
              onPressed: widget.onNext,
              style: widget.theme.nextButtonStyle,
              child: const Text('Next'),
            ),
        ],
        if (widget.onSkip != null)
          TextButton(
            onPressed: widget.onSkip,
            style: widget.theme.skipButtonStyle,
            child: const Text('Skip'),
          ),
        if (widget.onClose != null)
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            style: widget.theme.closeButtonStyle,
          ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    // This would need to be connected to the showcase controller
    // to get the current step index and total steps
    return LinearProgressIndicator(
      value: 0.5, // Placeholder - should be calculated
      backgroundColor: widget.theme.progressIndicatorBackgroundColor,
      valueColor: AlwaysStoppedAnimation<Color>(
        widget.theme.progressIndicatorColor ?? 
        Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildArrow() {
    if (_calculatedPosition == null) return const SizedBox.shrink();
    
    return Positioned(
      left: _calculatedPosition!.arrowOffset.dx - widget.theme.arrowSize,
      top: _calculatedPosition!.arrowOffset.dy - widget.theme.arrowSize,
      child: CustomPaint(
        size: Size(widget.theme.arrowSize * 2, widget.theme.arrowSize * 2),
        painter: ArrowPainter(
          direction: _calculatedPosition!.arrowDirection,
          color: widget.theme.arrowColor ?? 
                 widget.theme.tooltipBackgroundColor ?? 
                 Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}

/// Represents the calculated position of a tooltip.
class TooltipPosition {
  /// Creates a tooltip position.
  const TooltipPosition({
    required this.placement,
    required this.offset,
    required this.arrowOffset,
    required this.arrowDirection,
  });

  /// The placement of the tooltip.
  final TooltipPlacement placement;

  /// The offset of the tooltip.
  final Offset offset;

  /// The offset of the arrow.
  final Offset arrowOffset;

  /// The direction of the arrow.
  final ArrowDirection arrowDirection;
}

/// Direction of the tooltip arrow.
enum ArrowDirection {
  up,
  down,
  left,
  right,
}

/// Custom painter for bubble tooltips with arrows.
class BubbleTooltipPainter extends CustomPainter {
  /// Creates a bubble tooltip painter.
  const BubbleTooltipPainter({
    required this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    required this.shadowColor,
    required this.shadowBlur,
    required this.shadowOffset,
    required this.arrowDirection,
    required this.arrowSize,
    required this.borderRadius,
  });

  final Color backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;
  final ArrowDirection arrowDirection;
  final double arrowSize;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur);

    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = borderColor ?? Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Create the main bubble path
    final RRect bubbleRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    // Create the arrow path
    final Path arrowPath = _createArrowPath(size);

    // Combine bubble and arrow
    final Path combinedPath = Path()
      ..addRRect(bubbleRect)
      ..addPath(arrowPath, Offset.zero);

    // Draw shadow
    canvas.drawPath(combinedPath, shadowPaint);

    // Draw background
    canvas.drawPath(combinedPath, backgroundPaint);

    // Draw border
    if (borderColor != null) {
      canvas.drawPath(combinedPath, borderPaint);
    }
  }

  Path _createArrowPath(Size size) {
    final Path path = Path();
    final double halfArrowSize = arrowSize / 2;

    switch (arrowDirection) {
      case ArrowDirection.up:
        path.moveTo(size.width / 2 - halfArrowSize, 0);
        path.lineTo(size.width / 2 + halfArrowSize, 0);
        path.lineTo(size.width / 2, -arrowSize);
        break;
      case ArrowDirection.down:
        path.moveTo(size.width / 2 - halfArrowSize, size.height);
        path.lineTo(size.width / 2 + halfArrowSize, size.height);
        path.lineTo(size.width / 2, size.height + arrowSize);
        break;
      case ArrowDirection.left:
        path.moveTo(0, size.height / 2 - halfArrowSize);
        path.lineTo(0, size.height / 2 + halfArrowSize);
        path.lineTo(-arrowSize, size.height / 2);
        break;
      case ArrowDirection.right:
        path.moveTo(size.width, size.height / 2 - halfArrowSize);
        path.lineTo(size.width, size.height / 2 + halfArrowSize);
        path.lineTo(size.width + arrowSize, size.height / 2);
        break;
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant BubbleTooltipPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.borderColor != borderColor ||
           oldDelegate.borderWidth != borderWidth ||
           oldDelegate.shadowColor != shadowColor ||
           oldDelegate.shadowBlur != shadowBlur ||
           oldDelegate.shadowOffset != shadowOffset ||
           oldDelegate.arrowDirection != arrowDirection ||
           oldDelegate.arrowSize != arrowSize ||
           oldDelegate.borderRadius != borderRadius;
  }
}

/// Custom painter for tooltip arrows.
class ArrowPainter extends CustomPainter {
  /// Creates an arrow painter.
  const ArrowPainter({
    required this.direction,
    required this.color,
  });

  final ArrowDirection direction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    switch (direction) {
      case ArrowDirection.up:
        path.moveTo(centerX, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case ArrowDirection.down:
        path.moveTo(centerX, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        break;
      case ArrowDirection.left:
        path.moveTo(0, centerY);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case ArrowDirection.right:
        path.moveTo(size.width, centerY);
        path.lineTo(0, 0);
        path.lineTo(0, size.height);
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) {
    return oldDelegate.direction != direction || oldDelegate.color != color;
  }
}
