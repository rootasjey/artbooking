import 'package:artbooking/screens/changelog_page.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

class ChangelogLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = '/changelog';

  @override
  List<String> get pathPatterns => [route];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: ChangelogPage(),
        key: ValueKey(route),
        title: "Changelog",
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
