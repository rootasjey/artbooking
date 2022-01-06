import 'package:artbooking/components/dark_elevated_button.dart';
import 'package:artbooking/components/main_app_bar/main_app_bar.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class UndefinedPage extends StatefulWidget {
  @override
  _UndefinedPageState createState() => _UndefinedPageState();
}

class _UndefinedPageState extends State<UndefinedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          MainAppBar(),
          SliverPadding(
            padding: const EdgeInsets.only(top: 60.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                Column(
                  children: <Widget>[
                    title(),
                    subtitle(),
                    illustration(),
                    navButton(),
                    quoteCard(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 300.0),
                    ),
                  ],
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }

  Widget quoteCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 400.0,
        child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: <Widget>[
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      // 'It is by getting lost that we learn.',
                      'When we are lost, what matters is to find our way back.',
                      style: Utilities.fonts.style(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget illustration() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 12.0,
        bottom: 12.0,
      ),
      child: Icon(
        UniconsLine.car_sideview,
        size: 40.0,
      ),
    );
  }

  Widget navButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
      child: DarkElevatedButton.large(
        onPressed: () => context.beamToNamed(HomeLocation.route),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Return on the way'),
        ),
      ),
    );
  }

  Widget subtitle() {
    final String location = Beamer.of(context)
            .currentBeamLocation
            .state
            .routeInformation
            .location ??
        '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Opacity(
        opacity: 0.6,
        child: RichText(
          text: TextSpan(
            text: 'Route for ',
            style: TextStyle(
              fontSize: 18.0,
              color: Theme.of(context).textTheme.bodyText1?.color,
            ),
            children: [
              TextSpan(
                text: location,
                style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ' is not defined.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget title() {
    return Text(
      '404',
      style: TextStyle(
        fontSize: 120.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
