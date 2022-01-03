import 'package:artbooking/components/dashboard_side_menu.dart';
import 'package:artbooking/components/upload_window/upload_window.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

/// Widget showing user's dashboard.
class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _beamerKey = GlobalKey<BeamerState>();

  @override
  Widget build(context) {
    return HeroControllerScope(
      controller: HeroController(),
      child: Material(
        child: Stack(
          children: [
            Row(
              children: [
                DashboardSideMenu(
                  beamerKey: _beamerKey,
                ),
                Expanded(
                  child: Material(
                    elevation: 6.0,
                    child: Beamer(
                      key: _beamerKey,
                      routerDelegate: BeamerDelegate(
                        locationBuilder: BeamerLocationBuilder(beamLocations: [
                          DashboardLocationContent(),
                        ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16.0,
              bottom: 16.0,
              child: UploadWindow(),
            ),
          ],
        ),
      ),
    );
  }
}
