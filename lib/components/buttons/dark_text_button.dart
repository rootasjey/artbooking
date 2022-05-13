import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class DarkTextButton extends StatelessWidget {
  const DarkTextButton({
    Key? key,
    this.onPressed,
    required this.child,
  }) : super(key: key);

  final void Function()? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
      style: TextButton.styleFrom(
        primary: Theme.of(context).textTheme.bodyText1?.color,
        textStyle: Utilities.fonts.body(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget large({
    void Function()? onPressed,
    required Widget child,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: Colors.black87,
        minimumSize: Size(200.0, 0.0),
        textStyle: Utilities.fonts.body(
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: child,
      ),
    );
  }
}
