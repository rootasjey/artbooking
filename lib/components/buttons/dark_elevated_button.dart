import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class DarkElevatedButton extends StatelessWidget {
  const DarkElevatedButton({
    Key? key,
    this.onPressed,
    required this.child,
  }) : super(key: key);

  /// Callback fired when this widget is pressed.
  final void Function()? onPressed;

  /// Child widget.
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
        textStyle: Utilities.fonts.body(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget large({
    void Function()? onPressed,
    required Widget child,
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    return Padding(
      padding: margin,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.black87,
          minimumSize: Size(340.0, 0.0),
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
      ),
    );
  }

  static Widget icon({
    required IconData iconData,
    required String labelValue,
    Function()? onPressed,
    Color? background,
    Color? foreground,
    double? elevation,
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    return Padding(
      padding: margin,
      child: ElevatedButton.icon(
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
            style: Utilities.fonts.body(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          primary: background ?? Constants.colors.clairPink,
          minimumSize: Size(200.0, 60.0),
        ),
      ),
    );
  }

  static Widget iconOnly({
    void Function()? onPressed,
    required Widget child,
    Color color = Colors.black,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 2.0,
          vertical: 10.0,
        ),
        child: child,
      ),
      style: ElevatedButton.styleFrom(
        primary: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        textStyle: Utilities.fonts.body(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
