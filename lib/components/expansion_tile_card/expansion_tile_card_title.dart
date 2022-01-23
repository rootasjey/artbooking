import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class ExpansionTileCardTitle extends StatelessWidget {
  const ExpansionTileCardTitle({
    Key? key,
    this.opacity = 0.8,
    required this.textValue,
  }) : super(key: key);

  final double opacity;
  final String textValue;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Text(
        textValue,
        style: Utilities.fonts.style(
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
