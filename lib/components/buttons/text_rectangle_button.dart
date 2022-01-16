import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class TextRectangleButton extends StatelessWidget {
  const TextRectangleButton({
    Key? key,
    this.onPressed,
    required this.icon,
    required this.label,
    this.primary,
  }) : super(key: key);

  final Function()? onPressed;
  final Widget icon;
  final Widget label;
  final Color? primary;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: OutlinedButton.styleFrom(
        primary: primary,
        shape: RoundedRectangleBorder(),
        textStyle: Utilities.fonts.style(
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(
          width: 2.0,
          color: Colors.black38.withOpacity(0.2),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 28.0,
          vertical: 18.0,
        ),
      ),
    );
  }
}
