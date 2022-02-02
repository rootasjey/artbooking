import 'package:artbooking/globals/constants.dart';
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
        minimumSize: Size(320.0, 0.0),
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

  static Widget icon({
    required IconData iconData,
    required String labelValue,
    Function()? onPressed,
    Color? background,
    Color? foreground,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Icon(
          iconData,
          color: foreground,
        ),
      ),
      label: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Text(
          labelValue,
          style: Utilities.fonts.style(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: background ?? Constants.colors.clairPink,
        minimumSize: Size(200.0, 60.0),
      ),
    );
  }
}
