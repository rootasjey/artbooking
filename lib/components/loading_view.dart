import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  LoadingView({
    this.size = 100.0,
    this.style = const TextStyle(
      fontSize: 20.0,
    ),
    required this.title,
    this.sliver = true,
  });

  final TextStyle style;
  final Widget title;
  final double size;
  final bool sliver;

  @override
  Widget build(BuildContext context) {
    if (sliver) {
      return SliverToBoxAdapter(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedAppIcon(),
            title,
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedAppIcon(),
        title,
      ],
    );
  }
}
