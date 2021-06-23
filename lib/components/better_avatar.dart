import 'package:artbooking/state/colors.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class BetterAvatar extends StatefulWidget {
  final VoidCallback? onTap;
  final ImageProvider<Object> image;
  final double size;
  final double elevation;

  /// Not used if onTap is null.
  final ColorFilter? colorFilter;

  BetterAvatar({
    required this.image,
    this.elevation = 4.0,
    this.onTap,
    this.size = 220.0,
    this.colorFilter,
  });

  @override
  _BetterAvatarState createState() => _BetterAvatarState();
}

class _BetterAvatarState extends State<BetterAvatar>
    with TickerProviderStateMixin {
  late Animation<double> scaleAnimation;
  late AnimationController scaleAnimationController;

  late double elevation;

  @override
  void initState() {
    super.initState();

    scaleAnimationController = AnimationController(
      lowerBound: 0.8,
      upperBound: 1.0,
      duration: 500.milliseconds,
      vsync: this,
    );

    scaleAnimation = CurvedAnimation(
      parent: scaleAnimationController,
      curve: Curves.fastOutSlowIn,
    );

    setState(() {
      elevation = widget.elevation;
    });
  }

  @override
  dispose() {
    scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return withoutLink();
    }

    return withLink();
  }

  Widget withLink() {
    final size = widget.size;

    return ScaleTransition(
      scale: scaleAnimation,
      child: Material(
        elevation: elevation,
        color: stateColors.lightBackground,
        clipBehavior: Clip.antiAlias,
        shape: CircleBorder(
          side: BorderSide(
            color: stateColors.primary,
            width: 3.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            clipBehavior: Clip.antiAlias,
            shape: CircleBorder(),
            child: SizedBox(
              width: size,
              height: size,
              child: Ink.image(
                image: widget.image,
                width: size,
                height: size,
                fit: BoxFit.cover,
                colorFilter: widget.colorFilter,
                child: InkWell(
                  onTap: widget.onTap,
                  onHover: (isHover) {
                    if (isHover) {
                      elevation = (widget.elevation + 1.0) * 2;
                      scaleAnimationController.forward();
                      setState(() {});
                      return;
                    }

                    elevation = widget.elevation;
                    scaleAnimationController.reverse();
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget withoutLink() {
    final size = widget.size;

    return Material(
      elevation: elevation,
      color: stateColors.lightBackground,
      clipBehavior: Clip.antiAlias,
      shape: CircleBorder(
        side: BorderSide(
          color: stateColors.primary,
          width: 3.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          clipBehavior: Clip.antiAlias,
          shape: CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Image(
              image: widget.image,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
