import 'package:artbooking/state/colors.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:flutter/material.dart';

class SectionCard extends StatefulWidget {
  const SectionCard({
    Key? key,
    this.hoverColor = Colors.pink,
    required IconData this.iconData,
    required String this.textTitle,
    required String this.textSubtitle, this.onTap,
  }) : super(key: key);

  final IconData iconData;
  final String textTitle;
  final String textSubtitle;
  final Color hoverColor;
  final Function()? onTap;

  @override
  _SectionCardState createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  double _elevation = 2.0;
  Color? _iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.0,
      height: 116.0,
      child: Card(
        elevation: _elevation,
        color: stateColors.clairPink,
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
              style: FontsUtils.mainStyle(
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
              style: FontsUtils.mainStyle(
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
