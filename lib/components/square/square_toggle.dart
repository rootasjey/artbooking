import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class SquareToggle extends StatefulWidget {
  const SquareToggle({
    Key? key,
    required this.initialActive,
    this.onChangeValue,
  }) : super(key: key);

  final bool initialActive;
  final Function(bool)? onChangeValue;

  @override
  State<SquareToggle> createState() => _SquareToggleState();
}

class _SquareToggleState extends State<SquareToggle> {
  bool _isActive = false;

  @override
  initState() {
    super.initState();
    setState(() {
      _isActive = widget.initialActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return SizedBox(
      width: 100.0,
      height: 100.0,
      child: Card(
        elevation: _isActive ? 2.0 : 0.0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: _isActive ? primaryColor : primaryColor.withOpacity(0.6),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: InkWell(
          onTap: () {
            setState(() => _isActive = !_isActive);
            widget.onChangeValue?.call(_isActive);
          },
          onHover: (isHover) {},
          child: Center(
            child: Opacity(
              opacity: 0.6,
              child: Text(
                _isActive ? "on".tr().toUpperCase() : "off".tr().toUpperCase(),
                style: Utilities.fonts.body(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
