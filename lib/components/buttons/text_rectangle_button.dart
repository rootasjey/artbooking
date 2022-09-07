import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class TextRectangleButton extends StatelessWidget {
  const TextRectangleButton({
    Key? key,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.onPressed,
    this.primary,
    this.compact = false,
  }) : super(key: key);

  /// This button will take less space if this is true.
  final bool compact;

  /// Primary color.
  final Color? primary;

  /// Button's background color.
  final Color? backgroundColor;

  /// Callback fired when this button is pressed.
  final void Function()? onPressed;

  /// Icon widget to display as leading content inside the button.
  /// Typically an `Icon` widget.
  final Widget icon;

  /// Content widget to display as main content inside the button.
  /// Typically a `Text` widget.
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        primary: primary,
        shape: RoundedRectangleBorder(),
        textStyle: Utilities.fonts.body(
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(
          width: 2.0,
          color: Colors.black38.withOpacity(0.2),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 28.0,
          vertical: compact ? 10.0 : 18.0,
        ),
      ),
    );
  }
}
