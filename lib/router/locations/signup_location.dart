import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/screens/connection/signup_page.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = '/signup';

  @override
  List<String> get pathPatterns => [route];

  @override
  List<BeamGuard> get guards => [
        BeamGuard(
          pathPatterns: [route],
          check: (context, location) {
            final providerContainer = ProviderScope.containerOf(
              context,
              listen: false,
            );

            final isAuthenticated = providerContainer
                .read(AppState.userProvider.notifier)
                .isAuthenticated;

            return !isAuthenticated;
          },
          beamToNamed: (origin, target) => HomeLocation.route,
        ),
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: SignupPage(),
        key: ValueKey(route),
        title: Utilities.getPageTitle("signup".tr()),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
