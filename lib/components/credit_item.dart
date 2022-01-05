import 'package:flutter/material.dart';

class CreditItem extends StatefulWidget {
  const CreditItem({
    Key? key,
    this.onTap,
    this.hoverColor,
    this.iconData,
    this.opacity = 0.6,
    this.baseColor = Colors.white,
    required this.textValue,
  }) : super(key: key);

  final Function? onTap;
  final IconData? iconData;
  final Color? hoverColor;
  final Color baseColor;
  final double opacity;
  final String textValue;

  @override
  _CreditItemState createState() => _CreditItemState();
}

class _CreditItemState extends State<CreditItem> {
  Color baseColor = Colors.white.withOpacity(0.6);
  Color currentColor = Colors.white;
  Color hoverColor = Colors.amber;

  @override
  void initState() {
    super.initState();
    setState(() {
      hoverColor = widget.hoverColor ?? currentColor;
      baseColor = widget.baseColor;
      currentColor = baseColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap as void Function()?,
      onHover: (isHover) {
        if (isHover) {
          setState(() => currentColor = hoverColor);
          return;
        }

        setState(() => currentColor = baseColor);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 6.0,
        ),
        child: Row(
          children: <Widget>[
            if (widget.iconData != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  widget.iconData,
                  color: currentColor,
                ),
              ),
            Expanded(
              // child: widget.title,
              child: Opacity(
                opacity: widget.opacity,
                child: Text(
                  widget.textValue,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
