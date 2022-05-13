import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class AtelierPageCard extends StatefulWidget {
  const AtelierPageCard({
    Key? key,
    this.hoverColor = Colors.pink,
    required IconData this.iconData,
    required String this.textTitle,
    required String this.textSubtitle,
    this.compact = false,
    this.onTap,
  }) : super(key: key);

  final bool compact;
  final IconData iconData;
  final String textTitle;
  final String textSubtitle;
  final Color hoverColor;
  final Function()? onTap;

  @override
  _AtelierPageCardState createState() => _AtelierPageCardState();
}

class _AtelierPageCardState extends State<AtelierPageCard> {
  double _elevation = 2.0;
  Color? _iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.compact ? 200.0 : 300.0,
      height: 116.0,
      child: Card(
        elevation: _elevation,
        color: Constants.colors.clairPink,
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
      ),
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
