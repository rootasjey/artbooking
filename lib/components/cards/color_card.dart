import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/named_color.dart';
import 'package:flutter/material.dart';

class ColorCard extends StatelessWidget {
  const ColorCard({
    Key? key,
    this.selected = false,
    required this.namedColor,
    this.borderSide = BorderSide.none,
    this.onTap,
  }) : super(key: key);

  final bool selected;
  final NamedColor namedColor;
  final BorderSide borderSide;
  final void Function(NamedColor)? onTap;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Column(
      children: [
        SizedBox(
          width: 100.0,
          height: 100.0,
          child: Card(
            color: namedColor.color,
            shape: RoundedRectangleBorder(
              side: borderSide,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: InkWell(
              onTap: () => onTap?.call(namedColor),
            ),
          ),
        ),
        Opacity(
          opacity: 0.7,
          child: Text(
            namedColor.name,
            style: Utilities.fonts.body(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: selected ? primaryColor : null,
            ),
          ),
        ),
      ],
    );
  }
}
