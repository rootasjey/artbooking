import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class DarkOutlinedButton extends StatelessWidget {
  const DarkOutlinedButton({
    Key? key,
    this.onPressed,
    required this.child,
    this.selected = false,
  }) : super(key: key);

  final Function()? onPressed;
  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color baseColor =
        Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.6) ??
            Colors.black;

    return OutlinedButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 6.0,
        ),
        child: child,
      ),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        side: selected
            ? BorderSide(
                color: primaryColor,
                width: 2.0,
              )
            : null,
        primary: selected ? primaryColor : baseColor.withOpacity(0.4),
        textStyle: Utilities.fonts.style(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
