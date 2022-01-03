import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/screens/signin_page.dart';
import 'package:artbooking/types/globals/globals.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

class SigninLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = '/signin';

  @override
  List<String> get pathPatterns => [route];

  @override
  List<BeamGuard> get guards => [
        BeamGuard(
          pathPatterns: [route],
          check: (context, location) {
            final userNotifier = Globals.state.getUserNotifier();
            return !userNotifier.isAuthenticated;
          },
          beamToNamed: (origin, target) => HomeLocation.route,
        ),
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: SigninPage(),
        key: ValueKey(route),
        title: "Signin",
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
