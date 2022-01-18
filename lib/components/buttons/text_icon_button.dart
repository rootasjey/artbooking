import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class TextButtonIcon extends StatelessWidget {
  const TextButtonIcon({
    Key? key,
    required this.child,
    this.leading,
    this.trailing,
    this.onTap,
    this.compact = false,
    this.tooltip,
  }) : super(key: key);

  /// If true, show only the icon as an [IconButton].
  /// Else show a [Widget] similar to a [TextButton] with a [leading] icon.
  final bool compact;

  /// Text that describes the action that will occur when the button is pressed.
  /// This text is displayed when the user long-presses on the button
  /// and is used for accessibility.
  final String? tooltip;

  final VoidCallback? onTap;

  final Widget child;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return iconButton();
    }

    return iconWithLabel();
  }

  Widget iconButton() {
    if (leading == null) {
      Utilities.logger.w(
        "This [UnderlinedButton] component doesn't have a [leading]"
        "widget property, so it cannot be rendered in compact form.",
      );

      return Container();
    }

    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: leading!,
    );
  }

  Widget iconWithLabel() {
    return TextButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) leading!,
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Stack(
                children: [
                  child,
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
