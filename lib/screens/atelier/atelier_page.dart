import 'package:artbooking/screens/atelier/atelier_page_side_menu.dart';
import 'package:artbooking/components/upload_panel/upload_panel.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

/// Widget showing user's dashboard.
class AtelierPage extends StatefulWidget {
  @override
  _AtelierPageState createState() => _AtelierPageState();
}

class _AtelierPageState extends State<AtelierPage> {
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
                AtelierPageSideMenu(
                  beamerKey: _beamerKey,
                ),
                Expanded(
                  child: Material(
                    elevation: 6.0,
                    child: Beamer(
                      key: _beamerKey,
                      routerDelegate: BeamerDelegate(
                        locationBuilder: BeamerLocationBuilder(beamLocations: [
                          AtelierLocationContent(),
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
