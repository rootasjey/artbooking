import 'package:artbooking/screens/dashboard.dart';
import 'package:artbooking/screens/home/home.dart';
import 'package:artbooking/state/colors.dart';
import 'package:flutter/material.dart';

class MainWeb extends StatefulWidget {
  @override
  _MainWebState createState() => _MainWebState();
}

class _MainWebState extends State<MainWeb> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtBooking',
      theme: stateColors.themeData,
      debugShowCheckedModeBanner: false,
      // home: Home(),
      home: Dashboard(),
    );
  }
}
