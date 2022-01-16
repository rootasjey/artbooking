import 'package:artbooking/types/enums/enum_ani_props.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

/// Animate translateX and opacity of a child widget.
class FadeInX extends StatelessWidget {
  final Duration delay;
  final Widget? child;

  final double beginX;
  final double endX;

  FadeInX({
    this.beginX = 0.0,
    this.child,
    this.delay = const Duration(seconds: 0),
    this.endX = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<EnumAniProps>()
      ..add(EnumAniProps.opacity, 0.0.tweenTo(1.0), 500.milliseconds)
      ..add(EnumAniProps.translateX, Tween(begin: beginX, end: endX),
          500.milliseconds);

    return PlayAnimation<MultiTweenValues<EnumAniProps>>(
      tween: tween,
      delay: delay,
      duration: tween.duration,
      child: child,
      builder: (context, child, value) {
        return Opacity(
          opacity: value.get(EnumAniProps.opacity),
          child: Transform.translate(
            offset: Offset(value.get(EnumAniProps.translateX), 0),
            child: child,
          ),
        );
      },
    );
  }
}
