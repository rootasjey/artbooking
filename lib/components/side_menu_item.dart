import 'package:flutter/material.dart';

class SideMenuItem {
  final IconData iconData;
  final int index;
  final String label;
  final Color hoverColor;
  final String path;

  const SideMenuItem({
    required this.iconData,
    required this.index,
    required this.label,
    required this.hoverColor,
    required this.path,
  });
}
