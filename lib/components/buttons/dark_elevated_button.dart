import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class DarkElevatedButton extends StatelessWidget {
  const DarkElevatedButton({
    Key? key,
    this.onPressed,
    required this.child,
  }) : super(key: key);

  final void Function()? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
        child: child,
      ),
      style: ElevatedButton.styleFrom(
        primary: Colors.black,
        shape: RoundedRectangleBorder(),
        textStyle: Utilities.fonts.style(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget large({
    Function()? onPressed,
    required Widget child,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.black87,
        minimumSize: Size(200.0, 0.0),
        textStyle: Utilities.fonts.style(
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
