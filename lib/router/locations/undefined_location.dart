import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/undefined_page.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

class UndefinedLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = '*';

  @override
  List<String> get pathPatterns => [route];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: UndefinedPage(),
        key: ValueKey(route),
        title: Utilities.ui.getPageTitle("404"),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
