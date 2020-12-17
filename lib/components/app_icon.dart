import 'package:artbooking/screens/home/home_desktop.dart';
import 'package:flutter/material.dart';

class AppIcon extends StatefulWidget {
  final Function onTap;
  final EdgeInsetsGeometry padding;
  final double size;

  AppIcon({
    this.onTap,
    this.padding = const EdgeInsets.symmetric(vertical: 80.0),
    this.size = 60.0,
  });

  @override
  _AppIconState createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Material(
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: Ink.image(
          image: AssetImage('assets/images/app-icon-90.png'),
          fit: BoxFit.cover,
          width: widget.size,
          height: widget.size,
          child: InkWell(
            onTap: widget.onTap ?? defaultOnTap,
          ),
        ),
      ),
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
