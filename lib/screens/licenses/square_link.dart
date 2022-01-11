import 'package:flutter/material.dart';

class SquareLink extends StatefulWidget {
  const SquareLink({
    Key? key,
    this.onTap,
    required this.icon,
    required this.text,
    this.active = true,
  }) : super(key: key);

  final Function()? onTap;
  final Widget icon;
  final Widget text;
  final bool active;

  @override
  State<SquareLink> createState() => _SquareLinkState();
}

class _SquareLinkState extends State<SquareLink> {
  double _elevation = 0.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.active ? 1.0 : 0.3,
      child: Column(
        children: [
          SizedBox(
            width: 100.0,
            height: 100.0,
            child: Card(
              elevation: _elevation,
              child: InkWell(
                onTap: widget.active ? widget.onTap : null,
                onHover: (isHover) {
                  if (!widget.active) {
                    return;
                  }

                  setState(() {
                    _elevation = isHover ? 4.0 : 0.0;
                  });
                },
                child: Opacity(
                  opacity: 0.6,
                  child: widget.icon,
                ),
              ),
            ),
          ),
          Opacity(
            opacity: 0.6,
            child: widget.text,
          ),
        ],
      ),
    );
  }
}
