import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class FooterColumn extends StatelessWidget {
  const FooterColumn({
    Key? key,
    this.titleValue = "",
    required this.children,
  }) : super(key: key);

  final String titleValue;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titleValue.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: 14.0,
              bottom: 8.0,
            ),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                titleValue,
                style: Utilities.fonts.body2(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ...children,
      ],
    );
  }
}
