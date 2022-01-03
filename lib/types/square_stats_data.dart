import 'package:flutter/material.dart';

class SquareStatsData {
  SquareStatsData({
    required this.borderColor,
    required this.icon,
    required this.count,
    required this.titleValue,
    required this.routePath,
  });

  final Color borderColor;
  final Widget icon;
  final String routePath;
  final int count;
  final String titleValue;
}
