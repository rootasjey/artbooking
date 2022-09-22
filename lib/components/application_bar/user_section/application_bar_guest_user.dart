import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/buttons/dark_text_button.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:artbooking/router/locations/signin_location.dart';
import 'package:artbooking/router/locations/signup_location.dart';

class ApplicationBarGuestUser extends StatelessWidget {
  const ApplicationBarGuestUser({
    Key? key,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    if (isMobileSize) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.only(
        top: isMobileSize ? 5.0 : 0.0,
        bottom: isMobileSize ? 0.0 : 6.0,
        right: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: DarkTextButton(
              child: Text("signup".tr()),
              onPressed: () => Beamer.of(context).beamToNamed(
                SignupLocation.route,
              ),
            ),
          ),
          DarkElevatedButton(
            onPressed: () => Beamer.of(context).beamToNamed(
              SigninLocation.route,
            ),
            child: Text("signin".tr()),
          ),
        ],
      ),
    );
  }
}
