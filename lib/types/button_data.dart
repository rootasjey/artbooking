import 'package:flutter/widgets.dart';

class ButtonData {
  ButtonData({
    required this.textValue,
    required this.routePath,
    this.iconData,
  });

  final String textValue;
  final String routePath;
  final IconData? iconData;
}
