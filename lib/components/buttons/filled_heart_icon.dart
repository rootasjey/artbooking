import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unicons/unicons.dart';

/// A filled heart icon.
/// It's a stack of multiple icons since vanilla ones are not satifying.
class FilledHeartIcon extends StatelessWidget {
  const FilledHeartIcon({
    Key? key,
    this.size = 16.0,
  }) : super(key: key);

  /// Size of this icon.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 2.0,
          top: 2.0,
          child: Icon(
            FontAwesomeIcons.solidHeart,
            color: Theme.of(context).secondaryHeaderColor,
            size: size - 4.0,
            // size: 12.0,
          ),
        ),
        Icon(UniconsLine.heart, size: size),
        // Icon(UniconsLine.heart, size: 16.0),
      ],
    );
  }
}
