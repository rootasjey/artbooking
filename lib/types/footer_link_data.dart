import 'package:flutter/material.dart';

class FooterLinkData {
  FooterLinkData({
    this.heroTag,
    required this.label,
    required this.onPressed,
  });

  final String? heroTag;
  final String label;
  final VoidCallback onPressed;
}
