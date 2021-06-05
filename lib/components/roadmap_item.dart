import 'package:flutter/material.dart';

class RoadmapItemData {
  final String title;
  final IconData iconData;
  final String deadline;
  final String summary;

  const RoadmapItemData({
    Key key,
    this.title,
    this.iconData,
    this.deadline,
    this.summary,
  });
}
