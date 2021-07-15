import 'package:artbooking/screens/home_page.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

class HomeLocation extends BeamLocation {
  /// Main root value for this location.
  static const String route = '/';

  @override
  List<String> get pathBlueprints => [route];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: HomePage(),
        key: ValueKey(route),
        title: "Home",
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
