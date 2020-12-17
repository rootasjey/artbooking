import 'package:artbooking/state/colors.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class MainMobile extends StatefulWidget {
  @override
  MainMobileState createState() => MainMobileState();
}

class MainMobileState extends State<MainMobile> {
  @override
  void initState() {
    super.initState();
    loadBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtBooking',
      theme: stateColors.themeData,
      debugShowCheckedModeBanner: false,
    );
  }

  void loadBrightness() {
    final now = DateTime.now();

    Brightness brightness = Brightness.light;

    if (now.hour < 6 || now.hour > 17) {
      brightness = Brightness.dark;
    }

    Future.delayed(2.seconds, () {
      try {
        DynamicTheme.of(context).setBrightness(brightness);
        stateColors.refreshTheme(brightness);
      } catch (error) {
        debugPrint(error.toString());
      }
    });
  }
}
