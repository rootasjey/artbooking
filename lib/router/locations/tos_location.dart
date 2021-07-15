import 'package:artbooking/screens/tos_page.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

class TosLocation extends BeamLocation {
  /// Main root value for this location.
  static const String route = '/tos';

  @override
  List<String> get pathBlueprints => [route];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: TosPage(),
        key: ValueKey(route),
        title: "Term of Services",
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
