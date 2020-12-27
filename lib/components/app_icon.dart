import 'package:artbooking/screens/home/home_desktop.dart';
import 'package:flutter/material.dart';

class AppIcon extends StatefulWidget {
  final Function onTap;
  final EdgeInsetsGeometry padding;
  final double size;

  AppIcon({
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.size = 40.0,
  });

  @override
  _AppIconState createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      child: InkWell(
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: widget.onTap ?? defaultOnTap,
        child: Image.asset(
          'assets/images/app-icon-96.png',
          fit: BoxFit.cover,
          width: widget.size,
          height: widget.size,
        ),
      ),
      padding: widget.padding,
    );
  }

  void defaultOnTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HomeDesktop(),
      ),
    );
  }
}
