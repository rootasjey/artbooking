import 'package:artbooking/router/locations/home_location.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class AppIcon extends StatefulWidget {
  AppIcon({
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.size = 40.0,
  });

  final Function? onTap;
  final EdgeInsetsGeometry padding;
  final double size;

  @override
  _AppIconState createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onTap,
        child: Image.asset(
          "assets/images/app_icon/circle_512x512.png",
          width: widget.size,
          height: widget.size,
        ),
      ),
      padding: widget.padding,
    );
  }

  void onTap() {
    if (widget.onTap != null) {
      return widget.onTap?.call();
    }

    Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
  }
}
