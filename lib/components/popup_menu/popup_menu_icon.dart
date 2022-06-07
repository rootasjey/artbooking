import 'package:flutter/material.dart';

/// A predefined icon widget style to use in popup menu item.
class PopupMenuIcon extends StatelessWidget {
  const PopupMenuIcon(
    this.iconData, {
    Key? key,
  }) : super(key: key);

  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconData,
      size: 20.0,
    );
  }
}
