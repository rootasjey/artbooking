import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget {
  const SquareButton({
    Key? key,
    required this.child,
    this.active = false,
    this.message,
    this.onTap,
    this.opacity = 0.4,
  }) : super(key: key);

  /// If true, this button is active.
  final bool active;

  /// Widget opacity.
  final double opacity;

  /// Callback fired when this button is tapped.
  final void Function()? onTap;

  /// Tooltip message.
  final String? message;

  /// Child widget to display as button's content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Widget _childWidget = InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2.0,
              color: active ? Colors.white54 : Colors.black54,
            ),
            color: active ? Theme.of(context).primaryColor : null,
          ),
          child: child,
        ),
      ),
    );

    if (message != null) {
      return Tooltip(
        message: message,
        child: _childWidget,
      );
    }

    return _childWidget;
  }
}
