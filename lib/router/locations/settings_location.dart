import 'package:artbooking/screens/settings/settings_page.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';

class SettingsLocation extends BeamLocation<BeamState> {
  static const String route = '/settings';

  @override
  List<Pattern> get pathPatterns => [route];

  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: SettingsPage(),
        key: ValueKey(route),
        title: 'Settings',
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
