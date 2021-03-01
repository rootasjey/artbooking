import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class AnimatedAppIcon extends StatefulWidget {
  final double size;
  final String textTitle;

  AnimatedAppIcon({
    this.size = 100.0,
    this.textTitle,
  });

  @override
  _AnimatedAppIconState createState() => _AnimatedAppIconState();
}

class _AnimatedAppIconState extends State<AnimatedAppIcon> with AnimationMixin {
  Animation<Color> _colorAnimation;
  AnimationController _colorController;

  @override
  initState() {
    super.initState();

    _colorController = createController()..mirror(duration: 3.seconds);

    _colorAnimation =
        Colors.blue.tweenTo(Colors.pink).animatedBy(_colorController);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/app-icon-96.png',
          height: widget.size,
          width: widget.size,
        ),
        SizedBox(
          width: 100.0,
          child: LinearProgressIndicator(
            valueColor: _colorAnimation,
          ),
        ),
        if (widget.textTitle != null)
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
            ),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                widget.textTitle,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
