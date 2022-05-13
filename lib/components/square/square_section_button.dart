import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class SquareSectionButton extends StatefulWidget {
  const SquareSectionButton({
    Key? key,
    required this.iconData,
    this.iconColor,
    required this.textValue,
    this.onTap,
    this.cardColor = const Color(0xFFf5eaf9),
  }) : super(key: key);

  final IconData iconData;
  final Color? iconColor;
  final Color cardColor;
  final String textValue;
  final void Function()? onTap;

  @override
  _SquareSectionButtonState createState() => _SquareSectionButtonState();
}

class _SquareSectionButtonState extends State<SquareSectionButton> {
  /// Card's elevation.
  double _elevation = 0.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150.0,
      height: 150.0,
      child: Card(
        elevation: _elevation,
        color: widget.cardColor,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (isHover) {
            setState(() {
              _elevation = isHover ? 2.0 : 0.0;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Opacity(
              opacity: 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    widget.iconData,
                    size: 42.0,
                    color: _elevation == 0.0 ? null : widget.iconColor,
                  ),
                  Text(
                    widget.textValue,
                    textAlign: TextAlign.center,
                    style: Utilities.fonts.body(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
