import 'package:artbooking/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class UnderlinedButton extends StatefulWidget {
  final Color? hoverColor;
  final Color underlineColor;
  final VoidCallback? onTap;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;

  /// If true, show only the icon as an [IconButton].
  /// Else show a [Widget] similar to a [TextButton] with a [leading] icon.
  final bool compact;

  /// Text that describes the action that will occur when the button is pressed.
  /// This text is displayed when the user long-presses on the button
  /// and is used for accessibility.
  final String? tooltip;

  const UnderlinedButton({
    Key? key,
    this.hoverColor,
    this.underlineColor = Colors.black45,
    required this.child,
    this.leading,
    this.trailing,
    this.onTap,
    this.compact = false,
    this.tooltip,
  }) : super(key: key);

  @override
  _UnderlinedButtonState createState() => _UnderlinedButtonState();
}

class _UnderlinedButtonState extends State<UnderlinedButton>
    with AnimationMixin {
  late Animation<Offset> _slideAnimation;
  late Animation<double> _underlineAnimation;

  double? right;
  double? width = 0.0;

  @override
  void initState() {
    super.initState();

    _slideAnimation =
        Offset.zero.tweenTo(Offset(0.2, 0.0)).animatedBy(controller);

    _underlineAnimation =
        50.0.tweenTo(0.0).curved(Curves.decelerate).animatedBy(controller);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return iconButton();
    }

    return iconWithLabel();
  }

  Widget iconButton() {
    if (widget.leading == null) {
      appLogger.w(
        "This [UnderlinedButton] component doesn't have a [leading]"
        "widget property, so it cannot be rendered in compact form.",
      );

      return Container();
    }

    return IconButton(
      tooltip: widget.tooltip,
      onPressed: widget.onTap,
      icon: widget.leading!,
    );
  }

  Widget iconWithLabel() {
    return InkWell(
      hoverColor: widget.hoverColor,
      onTap: widget.onTap,
      onHover: (bool isHit) {
        if (isHit) {
          right = 40.0;
          width = null;
          controller.play(duration: 250.milliseconds);
          _underlineAnimation.addListener(underlineAnimListener);
          return;
        }

        _underlineAnimation.removeListener(underlineAnimListener);

        right = null;
        width = 0.0;
        controller.playReverse(duration: 250.milliseconds);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leading != null) widget.leading!,
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: Stack(
              children: [
                widget.child,
                Positioned(
                  left: 0.0,
                  right: right,
                  width: width,
                  bottom: 0.0,
                  child: Container(
                    color: widget.underlineColor,
                    height: 2.0,
                  ),
                ),
              ],
            ),
          ),
          if (widget.trailing != null)
            SlideTransition(
              position: _slideAnimation,
              child: widget.trailing,
            ),
        ],
      ),
    );
  }

  void underlineAnimListener() {
    right = _underlineAnimation.value;
  }
}
