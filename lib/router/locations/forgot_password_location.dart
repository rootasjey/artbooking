import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/settings/settings_page_forgot_password.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
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
        title: Utilities.ui.getPageTitle("password_forgot".tr()),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
