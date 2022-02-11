import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget {
  const SquareButton({
    Key? key,
    required this.child,
    this.message,
    this.onTap,
    this.opacity = 0.4,
  }) : super(key: key);

  final String? message;
  final void Function()? onTap;
  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                width: 2.0,
                color: Colors.black54,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
