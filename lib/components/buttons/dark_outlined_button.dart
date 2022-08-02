import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class DarkOutlinedButton extends StatelessWidget {
  const DarkOutlinedButton({
    Key? key,
    required this.child,
    this.accentColor,
    this.margin = EdgeInsets.zero,
    this.onPressed,
    this.selected = false,
  }) : super(key: key);

  /// This button will be highlited with `accentColor` if this is true.
  final bool selected;

  /// Button's main color (borders, text when selected).
  final Color? accentColor;

  final EdgeInsets margin;

  /// Callback fired when this button is pressed.
  final void Function()? onPressed;

  /// Child widget of this button.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor =
        accentColor != null ? accentColor! : primaryColor;
    final Color baseColor =
        Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.6) ??
            Colors.black;

    return Padding(
      padding: margin,
      child: OutlinedButton(
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
                  color: _accentColor,
                  width: 2.0,
                )
              : null,
          primary: selected ? _accentColor : baseColor.withOpacity(0.4),
          textStyle: Utilities.fonts.body(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
