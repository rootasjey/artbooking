import 'package:flutter/material.dart';

class ChangelogItem {
  ChangelogItem({
    required this.title,
    this.subtitle,
    this.date,
    required this.child,
    this.isExpanded = false,
  });

  bool isExpanded;
  final Widget title;
  final Widget? subtitle;
  final DateTime? date;
  Widget child;
}
