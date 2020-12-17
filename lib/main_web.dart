import 'package:artbooking/state/colors.dart';
import 'package:artbooking/utils/app_storage.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class MainWeb extends StatefulWidget {
  @override
  _MainWebState createState() => _MainWebState();
}

class _MainWebState extends State<MainWeb> {
  @override
  initState() {
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
    final autoBrightness = appStorage.getAutoBrightness();

    if (!autoBrightness) {
      final currentBrightness = appStorage.getBrightness();
      stateColors.refreshTheme(currentBrightness);

      return;
    }

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
