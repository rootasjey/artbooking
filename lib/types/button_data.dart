import 'package:flutter/widgets.dart';

class ButtonData {
  final String textValue;
  final String routePath;
  final IconData? iconData;

  ButtonData({
    required this.textValue,
    required this.routePath,
    this.iconData,
  });
}
