import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/settings/settings_page.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
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
        title: Utilities.ui.getPageTitle("settings".tr()),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
