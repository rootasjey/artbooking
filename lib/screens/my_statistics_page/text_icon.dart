import 'package:flutter/material.dart';

class TextIcon extends StatelessWidget {
  const TextIcon({
    Key? key,
    required this.icon,
    required this.richText,
  }) : super(key: key);

  final Widget icon;
  final RichText richText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Opacity(
            opacity: 0.6,
            child: icon,
          ),
          richText,
        ],
      ),
    );
  }
}
