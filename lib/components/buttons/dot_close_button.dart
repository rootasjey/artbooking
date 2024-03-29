import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A close button in the shape of a little pink dot.
class DotCloseButton extends StatefulWidget {
  const DotCloseButton({
    Key? key,
    this.onTap,
    this.tooltip = "cancel",
  }) : super(key: key);

  /// Fire when the user tap on this button.
  final Function()? onTap;

  /// Text to show when hovering this button.
  final String tooltip;

  @override
  _DotCloseButtonState createState() => _DotCloseButtonState();
}

class _DotCloseButtonState extends State<DotCloseButton> {
  /// True if the cursor is hover the widget.
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: InkWell(
        onTap: widget.onTap,
        onHover: onHover,
        child: Container(
          width: 16.0,
          height: 16.0,
          decoration: BoxDecoration(
            color: Theme.of(context).secondaryHeaderColor,
            shape: BoxShape.circle,
          ),
          child: Opacity(
            opacity: _isHover ? 1.0 : 0.0,
            child: Icon(
              UniconsLine.times,
              color: Colors.white,
              size: 14.0,
            ),
          ),
        ),
      ),
    );
  }

  void onHover(bool value) {
    setState(() {
      _isHover = value;
    });
  }
}
