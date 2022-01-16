import 'package:artbooking/screens/settings/settings_page_forgot_password.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

class ForgotPasswordLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = '/forgotpassword';

  @override
  List<String> get pathPatterns => [route];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: SettingsPageForgotPassword(),
        key: ValueKey(route),
        title: "Forgot Password",
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
