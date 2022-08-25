import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class ThemedCircularProgress extends StatefulWidget {
  const ThemedCircularProgress({
    Key? key,
    this.margin = EdgeInsets.zero,
    this.begin = Colors.amber,
    this.end = Colors.pink,
  }) : super(key: key);

  final EdgeInsets margin;
  final Color begin;
  final Color end;

  @override
  State<ThemedCircularProgress> createState() => _ThemedCircularProgressState();
}

class _ThemedCircularProgressState extends State<ThemedCircularProgress>
    with AnimationMixin {
  @override
  void initState() {
    super.initState();

    controller.duration = Duration(seconds: 3);
    controller.mirror();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.margin,
      child: CircularProgressIndicator(
        valueColor: controller.drive(
          ColorTween(begin: widget.begin, end: widget.end),
        ),
      ),
    );
  }
}
