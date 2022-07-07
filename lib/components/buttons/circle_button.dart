import 'package:flutter/material.dart';

/// An alternative to IconButton.
class CircleButton extends StatelessWidget {
  CircleButton({
    required this.icon,
    this.onTap,
    this.radius = 20.0,
    this.elevation = 0.0,
    this.backgroundColor = Colors.black12,
    this.tooltip,
    this.showBorder = false,
    this.margin = EdgeInsets.zero,
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

  /// This button's elevation. Shadow will be painted behind.
  final double elevation;

  /// Spacing outside of this button.
  final EdgeInsets margin;

  /// If true, will paint a border around this button.
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

    return Padding(
      padding: margin,
      child: Material(
        shape: CircleBorder(
          side: showBorder
              ? BorderSide(color: Colors.white38, width: 2.0)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        elevation: elevation,
        child: child,
      ),
    );
  }

  static Widget outlined({
    required final Function()? onTap,
    required final Widget child,
  }) {
    return Container(
      height: 28.0,
      width: 28.0,
      decoration: BoxDecoration(
        border: Border.all(width: 2.0),
        borderRadius: BorderRadius.circular(24.0),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.0),
        onTap: onTap,
        child: child,
      ),
    );
  }

  static Widget withNoEvent({
    required Icon icon,
    double radius = 20.0,
    double elevation = 0.0,
    Color backgroundColor = Colors.black12,
    String tooltip = "",
    bool showBorder = false,
  }) {
    return Material(
      shape: CircleBorder(
        side: showBorder
            ? BorderSide(color: Colors.white38, width: 2.0)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      elevation: elevation,
      child: CircleAvatar(
        child: icon,
        backgroundColor: backgroundColor,
        radius: radius,
      ),
    );
  }
}
