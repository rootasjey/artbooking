import 'package:artbooking/router/locations/home_location.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
        child: Lottie.asset(
          "assets/images/app_icon/icon_animation.json",
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
