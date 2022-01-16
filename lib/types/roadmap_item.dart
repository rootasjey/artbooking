import 'package:flutter/material.dart';

class RoadmapItemData {
  final String title;
  final IconData iconData;
  final String deadline;
  final String summary;

  const RoadmapItemData({
    Key? key,
    required this.title,
    required this.iconData,
    required this.deadline,
    required this.summary,
  });
}
