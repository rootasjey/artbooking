import 'package:artbooking/screens/search_page.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

class SearchLocation extends BeamLocation {
  /// Main root value for this location.
  static const String route = '/search';

  @override
  List<String> get pathBlueprints => [route];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: SearchPage(),
        key: ValueKey(route),
        title: "Search",
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
