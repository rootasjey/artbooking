import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({
    Key? key,
    this.titleValue,
    required this.children,
  }) : super(key: key);

  final String? titleValue;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titleValue != null)
          Padding(
            padding: const EdgeInsets.only(
              left: 14.0,
              bottom: 8.0,
            ),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                titleValue!,
                style: Utilities.fonts.style(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ...children,
      ],
    );
  }
}
