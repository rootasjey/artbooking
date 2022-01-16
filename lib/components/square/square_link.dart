import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SquareLink extends StatefulWidget {
  const SquareLink({
    Key? key,
    this.onTap,
    required this.icon,
    required this.text,
    this.active = true,
    this.checked = false,
    this.onLongPress,
  }) : super(key: key);

  final Function()? onTap;
  final Function()? onLongPress;
  final Widget icon;
  final Widget text;
  final bool active;
  final bool checked;

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
          Stack(
            children: [
              SizedBox(
                width: 100.0,
                height: 100.0,
                child: Card(
                  elevation: _elevation,
                  child: InkWell(
                    onTap: widget.active ? widget.onTap : null,
                    onLongPress: widget.active ? widget.onLongPress : null,
                    onHover: (isHover) {
                      if (!widget.active) {
                        return;
                      }

                      setState(() {
                        _elevation = isHover ? 4.0 : 0.0;
                      });
                    },
                    child: Opacity(
                      opacity: widget.checked ? 1.0 : 0.6,
                      child: widget.icon,
                    ),
                  ),
                ),
              ),
              if (widget.checked)
                Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: Icon(
                    UniconsLine.check,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
            ],
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
