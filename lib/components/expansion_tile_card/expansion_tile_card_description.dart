import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class ExpansionTileCardDescription extends StatelessWidget {
  const ExpansionTileCardDescription({
    Key? key,
    required this.textValue,
  }) : super(key: key);

  final String textValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 4.0,
        bottom: 8.0,
      ),
      child: Opacity(
        opacity: 0.6,
        child: Text(
          textValue,
          style: Utilities.fonts.body(),
        ),
      ),
    );
  }
}
