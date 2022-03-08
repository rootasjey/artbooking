import 'package:flutter/material.dart';

/// An alternative to IconButton.
class CircleButton extends StatelessWidget {
  CircleButton({
    this.onTap,
    required this.icon,
    this.radius = 20.0,
    this.elevation = 0.0,
    this.backgroundColor = Colors.black12,
    this.tooltip,
    this.showBorder = false,
  });

  /// Tap callback.
  final VoidCallback? onTap;

  final String? tooltip;

  /// Typically an Icon.
  final Widget icon;

  /// Size in radius of the widget.
  final double radius;

  /// Widget content backrgound color.
  final Color backgroundColor;

  final double elevation;

  // final BorderSide borderSide;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    Widget child = Ink(
      child: InkWell(
        onTap: onTap,
        child: CircleAvatar(
          child: icon,
          backgroundColor: backgroundColor,
          radius: radius,
        ),
      ),
    );

    if (tooltip != null) {
      child = Tooltip(
        message: tooltip,
        child: child,
      );
    }

    return Material(
      shape: CircleBorder(
        side: showBorder
            ? BorderSide(color: Colors.white38, width: 2.0)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      elevation: elevation,
      child: child,
    );
  }
}
