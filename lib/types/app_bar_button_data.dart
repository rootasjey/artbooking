import 'package:flutter/widgets.dart';

class AppBarButtonData {
  AppBarButtonData({
    required this.textValue,
    required this.routePath,
    this.iconData,
  });

  final String textValue;
  final String routePath;
  final IconData? iconData;
}
