import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class FooterLink extends StatelessWidget {
  const FooterLink({
    Key? key,
    this.onPressed,
    this.heroTag,
    required this.label,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final String? heroTag;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Widget textComponent = Text(
      label,
      style: Utilities.fonts.style2(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
    );

    Widget textContainer;

    if (heroTag != null) {
      textContainer = Hero(
        tag: label,
        child: textComponent,
      );
    } else {
      textContainer = textComponent;
    }

    return TextButton(
      onPressed: onPressed,
      child: Opacity(
        opacity: 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: textContainer,
        ),
      ),
      style: TextButton.styleFrom(
        primary: Theme.of(context).textTheme.bodyText1?.color,
      ),
    );
  }
}
