import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget {
  const SquareButton({
    Key? key,
    required this.child,
    this.message,
    this.onTap,
    this.opacity = 0.4,
    this.active = false,
  }) : super(key: key);

  final String? message;
  final void Function()? onTap;
  final Widget child;
  final double opacity;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final _childWidget = InkWell(
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
