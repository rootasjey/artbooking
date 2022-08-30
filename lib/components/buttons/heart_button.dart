import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_animations/anicoto/animation_mixin.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class HeartButton extends StatefulWidget {
  const HeartButton({
    Key? key,
    this.onTap,
    this.liked = false,
    this.margin = EdgeInsets.zero,
    this.autoReverse = false,
    this.asIconButton = false,
    this.tooltip,
  }) : super(key: key);

  final bool asIconButton;

  /// If true, the animation will play back in reverse
  /// to its initial value after completion.
  final bool autoReverse;

  /// If true, the icon is initially filled.
  final bool liked;

  /// Callback fired on a tap event.
  final void Function()? onTap;

  /// Margin around this widget.
  final EdgeInsets margin;

  /// ext that describes the action that will occur when the button is pressed.
  /// This text is displayed when the user long-presses on the button and is used for accessibility.
  final String? tooltip;

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> with AnimationMixin {
  late final AnimationController _heartAnimationController;
  TickerFuture? _heartAnimationTicker;

  late Animation<double> _scaleAnimation;
  late AnimationController _scaleAnimationController;

  /// This boolean is used to swap between static icon and lottie animation.
  /// We cannot display lottie animation all the time because of abusive repaint
  /// (Successive widget repaint causes UI jank).
  bool completed = true;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = createController();

    _scaleAnimationController = createController()..duration = 250.milliseconds;
    _scaleAnimation = 0.3
        .tweenTo(1.0)
        .animatedBy(_scaleAnimationController)
        .curve(Curves.elasticOut);
  }

  @override
  void dispose() {
    _heartAnimationTicker?.ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asIconButton) {
      return asIconButton();
    }

    return asInkWell();
  }

  Widget asIconButton() {
    return IconButton(
      tooltip: widget.tooltip,
      onPressed: () {
        widget.onTap?.call();
        _heartAnimationTicker?.ignore();

        completed = false;

        if (widget.liked) {
          _heartAnimationController.value = 1.0;
          _heartAnimationTicker = _heartAnimationController.animateBack(0.0);
        } else {
          _heartAnimationTicker = _heartAnimationController.forward();
        }

        _heartAnimationTicker?.orCancel.whenComplete(() => completed = true);

        if (widget.autoReverse) {
          _heartAnimationTicker?.orCancel
              .whenComplete(() => _heartAnimationController.reverse());
        }
      },
      icon: completed ? completedIconWidget() : uncompletedIconWidget(),
    );
  }

  Widget asInkWell() {
    return InkWell(
      onHover: (bool isHover) {
        if (isHover) {
          _scaleAnimationController.forward();
          return;
        }

        _scaleAnimationController.reverse();
      },
      onTap: () {
        widget.onTap?.call();
        _heartAnimationTicker?.ignore();
        _heartAnimationTicker = _heartAnimationController.forward();

        if (widget.autoReverse) {
          _heartAnimationTicker?.orCancel
              .whenComplete(() => _heartAnimationController.animateBack(0));
        }
      },
      child: Container(
        width: 20.0,
        height: 20.0,
        margin: widget.margin,
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
              controller: _heartAnimationController,
              onLoaded: (LottieComposition composition) {
                _heartAnimationController.duration = composition.duration;

                if (widget.liked) {
                  _heartAnimationController.value =
                      _heartAnimationController.upperBound;
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget completedIconWidget() {
    return Stack(
      children: [
        Positioned(
          left: widget.liked ? 3.0 : 0.0,
          top: widget.liked ? 2.0 : 0.0,
          child: Icon(
            widget.liked ? FontAwesomeIcons.solidHeart : UniconsLine.heart,
            size: widget.liked ? 18.0 : 24.0,
            color: widget.liked ? Theme.of(context).secondaryHeaderColor : null,
          ),
        ),
        if (widget.liked)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(UniconsLine.heart),
          ),
      ],
    );
  }

  Widget uncompletedIconWidget() {
    return Positioned(
      top: 2.0,
      left: 2.0,
      child: Container(
        width: 20.0,
        height: 20.0,
        margin: widget.margin,
        child: OverflowBox(
          maxWidth: 140.0,
          maxHeight: 140.0,
          child: Lottie.asset(
            "assets/animations/heart.json",
            width: 96.0,
            height: 72.0,
            fit: BoxFit.cover,
            alignment: Alignment.bottomLeft,
            controller: _heartAnimationController,
            onLoaded: (LottieComposition composition) {
              _heartAnimationController.duration = composition.duration;
            },
          ),
        ),
      ),
    );
  }
}
