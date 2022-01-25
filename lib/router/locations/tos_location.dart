import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/tos_page.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/widgets.dart';

class TosLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = '/tos';

  @override
  List<String> get pathPatterns => [route];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: TosPage(),
        key: ValueKey(route),
        title: Utilities.getPageTitle("tos".tr()),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
