import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  const TextDivider({
    Key? key,
    this.dividerColor = Colors.pink,
    required this.text,
  }) : super(key: key);

  final Color dividerColor;
  final Widget text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 6.0,
          width: 60.0,
          child: Divider(
            thickness: 1.5,
            color: dividerColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: text,
        ),
        SizedBox(
          height: 6.0,
          width: 60.0,
          child: Divider(
            thickness: 1.5,
            color: dividerColor,
          ),
        ),
      ],
    );
  }
}
