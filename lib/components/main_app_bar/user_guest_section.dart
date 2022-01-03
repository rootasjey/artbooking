import 'package:artbooking/components/dark_elevated_button.dart';
import 'package:artbooking/components/dark_text_button.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:artbooking/router/locations/signin_location.dart';
import 'package:artbooking/router/locations/signup_location.dart';

class UserGuestSection extends StatelessWidget {
  const UserGuestSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 5.0,
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
