import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class AtelierPageCard extends StatefulWidget {
  const AtelierPageCard({
    Key? key,
    required IconData this.iconData,
    required String this.textSubtitle,
    required String this.textTitle,
    this.backgroundColor = Colors.white,
    this.compact = false,
    this.hoverColor = Colors.pink,
    this.noSizeConstraints = false,
    this.onTap,
  }) : super(key: key);

  /// If true, this card won't have size constrains
  /// (height = 116.0 and width = 200 || 300).
  final bool noSizeConstraints;

  /// If true, the card's width will be 200.0.
  final bool compact;

  /// Card's background color.
  final Color backgroundColor;

  /// Icon will be of this color on hover.
  final Color hoverColor;

  /// Icon's data which will be displayed before text.
  final IconData iconData;

  /// Primary card's text.
  final String textTitle;

  /// Secondary card's text.
  final String textSubtitle;

  /// Callback fired when this card is tapped.
  final Function()? onTap;

  @override
  _AtelierPageCardState createState() => _AtelierPageCardState();
}

class _AtelierPageCardState extends State<AtelierPageCard> {
  /// Card's current elevation.
  double _elevation = 2.0;

  /// Card's current icon color.
  Color? _iconColor;

  @override
  Widget build(BuildContext context) {
    final Widget card = Card(
      elevation: _elevation,
      color: widget.backgroundColor,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (isHover) {
          if (isHover) {
            setState(() {
              _elevation = 4.0;
              _iconColor = widget.hoverColor;
            });
            return;
          }

          setState(() {
            _elevation = 2.0;
            _iconColor = null;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon(),
              texts(),
            ],
          ),
        ),
      ),
    );

    if (widget.noSizeConstraints) {
      return card;
    }

    return Container(
      width: widget.compact ? 200.0 : 300.0,
      height: 116.0,
      child: card,
    );
  }

  Widget icon() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Opacity(
        opacity: 0.6,
        child: Icon(
          widget.iconData,
          color: _iconColor,
        ),
      ),
    );
  }

  Widget texts() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.6,
            child: Text(
              widget.textTitle,
              style: Utilities.fonts.body(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Opacity(
            opacity: 0.4,
            child: Text(
              widget.textSubtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Utilities.fonts.body(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
