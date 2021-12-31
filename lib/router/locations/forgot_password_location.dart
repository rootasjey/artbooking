import 'package:artbooking/screens/forgot_password_page.dart';
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
        child: ForgotPasswordPage(),
        key: ValueKey(route),
        title: "Forgot Password",
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
