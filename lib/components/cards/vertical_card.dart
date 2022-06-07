import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class VerticalCard extends StatefulWidget {
  const VerticalCard({
    Key? key,
    required this.description,
    required this.icon,
    required this.title,
    this.height = 420.0,
    this.width = 300.0,
    this.onTap,
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  final double width;
  final double height;

  final Icon icon;
  final String title;
  final String description;

  final EdgeInsets margin;

  final void Function()? onTap;

  @override
  State<VerticalCard> createState() => _VerticalCardState();
}

class _VerticalCardState extends State<VerticalCard> {
  double _elevation = 4.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (bool isHover) {
          setState(() => _elevation = isHover ? 8.0 : 4.0);
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Card(
            elevation: _elevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: widget.icon,
                  ),
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      widget.title,
                      style: Utilities.fonts.title2(
                        fontSize: 32.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Opacity(
                      opacity: 0.6,
                      child: Text(
                        widget.description,
                        style: Utilities.fonts.body(
                          fontSize: 18.0,
                        ),
                      ),
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
