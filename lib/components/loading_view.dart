import 'package:artbooking/components/animated_app_icon.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  LoadingView({
    this.size = 100.0,
    this.style = const TextStyle(
      fontSize: 20.0,
    ),
    required this.title,
  });

  final TextStyle style;
  final Widget title;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedAppIcon(),
        title,
      ],
    );
  }
}
