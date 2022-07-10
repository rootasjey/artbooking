import 'package:flutter/material.dart';

class BottomActionBarButton extends StatelessWidget {
  const BottomActionBarButton({
    Key? key,
    required this.iconData,
    this.onPressed,
    this.tooltip,
  }) : super(key: key);

  /// This icon data will be wrapped inside an icon with a predefined style.
  final IconData iconData;

  /// Callback fired when the button is pressed.
  final void Function()? onPressed;

  /// Describe this purpose button to show a tooltip on pointer hover.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: IconButton(
        tooltip: tooltip,
        icon: Opacity(
          opacity: 0.6,
          child: Icon(iconData),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
