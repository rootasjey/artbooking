import 'dart:ui';

import 'package:artbooking/router/route_names.dart';
import 'package:artbooking/router/router.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              heroContent(),
              header(),
            ],
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Text(
              'Art Booking',
              style: GoogleFonts.amaticSc(
                color: stateColors.primary,
                fontSize: 30.0,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: userState.isConnected ?
              dashboardButton() :
              signinButton(),
          ),
        ],
      ),
    );
  }

  Widget dashboardButton() {
    return Material(
      elevation: 1.0,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: Ink.image(
        image: NetworkImage('https://drawinghowtos.com/wp-content/uploads/2019/04/fox-colored.png'),
        fit: BoxFit.cover,
        width: 60.0,
        height: 60.0,
        child: InkWell(
          onTap: () {
            return FluroRouter.router.navigateTo(context, DashboardRoute);
          },
        ),
      ),
    );
  }

  Widget signinButton() {
    return RaisedButton(
      onPressed: () {
        FluroRouter.router.navigateTo(context, SigninRoute);
      },
      color: stateColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'Sign in',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget heroContent() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Row(
        children: <Widget>[
          heroIllustration(),
          textIllustration(),
        ],
      ),
    );
  }

  Widget heroText() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Card(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
                // padding: const EdgeInsets.all(25.0),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text(
                    'Art Booking',
                    style: GoogleFonts.amaticSc(
                      color: Colors.green.shade300,
                      fontSize: 30.0,
                    ),
                  ),
                ),
              ),

              RaisedButton(
                onPressed: () {
                  FluroRouter.router.navigateTo(context, SigninRoute);
                },
                color: stateColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                ),
                child: Text(
                  'Sign in',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget textIllustration() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Illustration title',
            style: GoogleFonts.amaticSc(
              fontSize: 60.0,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
            ),
            child: Opacity(
              opacity: .6,
              child: Text(
                "Lore: It was a night of full moon. No sound around...",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget heroIllustration() {
    return Expanded(
      child: Material(
        elevation: 4.0,
        color: Colors.transparent,
        child: Ink.image(
          image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/art%2Fjeremie_corpinot%2FFlorale%2Fflorale_0_1080.png?alt=media&token=cd3a1f4d-f935-4cc7-b118-a9e6dca3de65'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn),
          height: MediaQuery.of(context).size.height,
          child: InkWell(
            onTap: () {},
            onHover: (hit) {},
          ),
        ),
      ),
    );
  }
}
