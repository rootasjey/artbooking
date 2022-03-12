import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/search_page.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/widgets.dart';

class SearchLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = '/search';

  @override
  List<String> get pathPatterns => [route];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: SearchPage(),
        key: ValueKey(route),
        title: Utilities.ui.getPageTitle("search".tr()),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
