import 'package:artbooking/utils/fonts.dart';
import 'package:flutter/material.dart';

class LandingHero extends StatefulWidget {
  @override
  _LandingHeroState createState() => _LandingHeroState();
}

class _LandingHeroState extends State<LandingHero> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 140.0,
        left: 60.0,
        right: 60.0,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          children: [
            title(),
          ],
        ),
      ),
    );
  }

  Widget title() {
    return Text(
      "ArtBooking",
      style: FontsUtils.title(
        fontSize: 90.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
