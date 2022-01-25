import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/home/home_page.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/widgets.dart';

class HomeLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = '/';

  @override
  List<String> get pathPatterns => [route];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: HomePage(),
        key: ValueKey(route),
        title: Utilities.getPageTitle("home".tr()),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
