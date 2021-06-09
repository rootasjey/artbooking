import 'package:artbooking/utils/fonts.dart';
import 'package:flutter/material.dart';

class DarkElevatedButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget child;

  const DarkElevatedButton({
    Key key,
    this.onPressed,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.black87,
        minimumSize: Size(200.0, 0.0),
        textStyle: FontsUtils.mainStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: child,
      ),
    );
  }
}
