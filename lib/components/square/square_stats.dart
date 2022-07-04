import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
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
    this.compact = false,
  }) : super(key: key);

  /// Card border's color.
  final Color? borderColor;

  /// If true, will reduce the default size of this square widget.
  final bool compact;

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
    final double size = widget.compact ? 160.0 : 220.0;

    return Opacity(
      opacity: widget.onTap == null ? 0.4 : 1.0,
      child: SizedBox(
        width: size,
        height: size,
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
  /// doesn't have an onTap function callback.
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
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 2.0 : 8.0,
            vertical: widget.compact ? 2.0 : 8.0,
          ),
          child: Text(
            "available_soon".tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Utilities.fonts.body(
              fontSize: widget.compact ? 14.0 : 16.0,
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
        style: Utilities.fonts.body(
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
        maxLines: widget.compact ? 1 : 3,
        overflow: TextOverflow.ellipsis,
        style: Utilities.fonts.body(
          color: _textColor,
          fontSize: widget.compact ? 14.0 : 20.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Return the card's border color
  /// based on the availability of the onTap function.
  Color getBorderColor() {
    if (widget.onTap == null) {
      return Colors.transparent;
    }

    return widget.borderColor ?? Colors.transparent;
  }

  /// Return the card's elevation
  /// based on the availability of the onTap function.
  double getElevation() {
    if (widget.onTap == null) {
      return 0.0;
    }

    return _elevation;
  }
}
