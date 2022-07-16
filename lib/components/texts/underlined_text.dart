import 'package:flutter/material.dart';

/// A widget to display some text with a custom underline decoration.
class UnderlinedText extends StatelessWidget {
  const UnderlinedText({
    Key? key,
    required this.textValue,
    this.underlinedColor = Colors.red,
    this.underlineHeight = 6.0,
    this.bottom = 4.0,
    this.style,
  }) : super(key: key);

  final Color underlinedColor;

  /// Uderline offset from bottom.
  final double bottom;

  /// Line's height.
  final double underlineHeight;

  final String textValue;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: bottom,
          left: 0.0,
          right: 0.0,
          child: Container(
            height: underlineHeight,
            color: underlinedColor,
          ),
        ),
        Text(
          textValue,
          style: style,
        ),
      ],
    );
  }
}
