import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:flutter/material.dart';

/// A card showing a statistic number, title and icon.
class SquareStats extends StatefulWidget {
  const SquareStats({
    Key? key,
    this.count = 0,
    this.icon,
    this.onTap,
    required this.textTitle,
    this.borderColor,
  }) : super(key: key);

  /// Card border's color.
  final Color? borderColor;

  /// This number will be display as the main information.
  final int count;

  /// Icon to show at the top of the card.
  final Widget? icon;

  /// Fire when an user tap on this card.
  final void Function()? onTap;

  /// String value to display below the [count].
  final String textTitle;

  @override
  _SquareStatsState createState() => _SquareStatsState();
}

class _SquareStatsState extends State<SquareStats> {
  /// Card's elevation.
  double _elevation = 2.0;

  /// Card's initial text color.
  Color _initialTextColor = Colors.black87;

  /// Card's current text color.
  Color _textColor = Colors.black87;

  /// Card's border width.
  double _borderWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.onTap == null ? 0.4 : 1.0,
      child: SizedBox(
        width: 220.0,
        height: 220.0,
        child: Card(
          color: Constants.colors.clairPink,
          elevation: getElevation(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: getBorderColor(),
              width: _borderWidth,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            onHover: (isHover) {
              if (isHover) {
                setState(() {
                  _borderWidth = 2.5;
                  _elevation = 4.0;
                  _textColor = getBorderColor();
                });

                return;
              }

              setState(() {
                _borderWidth = 2.0;
                _elevation = 2.0;
                _textColor = _initialTextColor;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Stack(
                children: [
                  availableSoonLabel(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      countWidget(),
                      titleWidget(),
                    ],
                  ),
                  iconWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Show a "soon" label if the card
  /// doesn't have an [onTap] function callback.
  Widget availableSoonLabel() {
    if (widget.onTap != null) {
      return Container();
    }

    return Positioned(
      top: 0.0,
      left: 0.0,
      child: Card(
        elevation: 0.0,
        color: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 8.0,
          ),
          child: Text(
            "Available soon",
            style: FontsUtils.mainStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Return the number of items as a widget.
  Widget countWidget() {
    return Opacity(
      opacity: 0.9,
      child: Text(
        widget.count.toString(),
        style: FontsUtils.mainStyle(
          color: _textColor,
          fontSize: 40.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Return the card's icon.
  Widget iconWidget() {
    if (widget.icon == null) {
      return Container();
    }

    return Positioned(
      top: 0.0,
      left: 0.0,
      child: Opacity(
        opacity: 0.6,
        child: widget.icon,
      ),
    );
  }

  Widget titleWidget() {
    return Opacity(
      opacity: 0.7,
      child: Text(
        widget.textTitle,
        style: FontsUtils.mainStyle(
          color: _textColor,
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Return the card's border color
  /// based on the availability of the [onTap] function.
  Color getBorderColor() {
    if (widget.onTap == null) {
      return Colors.transparent;
    }

    return widget.borderColor ?? Colors.transparent;
  }

  /// Return the card's elevation
  /// based on the availability of the [onTap] function.
  double getElevation() {
    if (widget.onTap == null) {
      return 0.0;
    }

    return _elevation;
  }
}
