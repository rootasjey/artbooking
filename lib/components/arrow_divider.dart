import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// Like a Divider() but with an arrow in the middle.
class ArrowDivider extends StatelessWidget {
  /// Padding outside the divider.
  final EdgeInsets padding;

  const ArrowDivider({
    Key key,
    this.padding = const EdgeInsets.only(top: 60.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = 100.0;

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: width, child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Opacity(
              opacity: 0.6,
              child: Icon(UniconsLine.arrow_down),
            ),
          ),
          SizedBox(width: width, child: Divider()),
        ],
      ),
    );
  }
}
