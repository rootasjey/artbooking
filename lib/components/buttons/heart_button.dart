import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_animations/anicoto/animation_mixin.dart';
import 'package:supercharged/supercharged.dart';

class HeartButton extends StatefulWidget {
  const HeartButton({
    Key? key,
    this.onTap,
  }) : super(key: key);

  final void Function()? onTap;

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> with AnimationMixin {
  late final AnimationController _animationController;
  TickerFuture? _heartAnimationTicker;

  late Animation<double> _scaleAnimation;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _animationController = createController();

    _scaleController = createController()..duration = 250.milliseconds;
    _scaleAnimation =
        0.3.tweenTo(1.0).animatedBy(_scaleController).curve(Curves.elasticOut);
  }

  @override
  void dispose() {
    _heartAnimationTicker?.ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (bool isHover) {
        if (isHover) {
          _scaleController.forward();
          return;
        }

        _scaleController.reverse();
      },
      onTap: () {
        widget.onTap?.call();
        _heartAnimationTicker?.ignore();
        _heartAnimationTicker = _animationController.forward();
        _heartAnimationTicker?.orCancel
            .whenComplete(() => _animationController.animateBack(0));
      },
      child: Container(
        width: 20.0,
        height: 20.0,
        margin: const EdgeInsets.only(left: 12.0),
        child: OverflowBox(
          maxWidth: 140.0,
          maxHeight: 140.0,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Lottie.asset(
              "assets/animations/heart.json",
              width: 96.0,
              height: 72.0,
              fit: BoxFit.cover,
              alignment: Alignment.bottomLeft,
              controller: _animationController,
              onLoaded: (LottieComposition cmposition) {
                _animationController.duration = cmposition.duration;
              },
            ),
          ),
        ),
      ),
    );
  }
}
