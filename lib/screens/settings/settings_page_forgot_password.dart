import 'package:artbooking/actions/users.dart';
import 'package:artbooking/components/animations/fade_in_x.dart';
import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/buttons/dark_text_button.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/texts/outlined_text_field.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/locations/signin_location.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class SettingsPageForgotPassword extends StatefulWidget {
  @override
  _SettingsPageForgotPasswordState createState() =>
      _SettingsPageForgotPasswordState();
}

class _SettingsPageForgotPasswordState
    extends State<SettingsPageForgotPassword> {
  String _email = "";

  bool _completed = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          ApplicationBar(),
          body(),
        ],
      ),
    );
  }

  Widget body() {
    if (_completed) {
      return completedContainer();
    }

    if (_loading) {
      return SliverPadding(
        padding: const EdgeInsets.only(top: 200.0),
        sliver: LoadingView(
          title: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "email_sending".tr() + "...",
                style: Utilities.fonts.body(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return idleContainer();
  }

  Widget completedContainer() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 100.0, bottom: 300.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Icon(
                UniconsLine.check_circle,
                size: 42.0,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Container(
              width: 500.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
                    child: Text(
                      "email_password_reset_link".tr(),
                      style: Utilities.fonts.title3(
                        fontSize: 42.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.6,
                    child: Text.rich(
                      TextSpan(
                        text: "email_password_reset_link_subtitle.1".tr(),
                        children: [
                          TextSpan(
                            text: _email,
                            style: Utilities.fonts.body(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextSpan(
                            text: "email_password_reset_link_subtitle.2".tr(),
                          ),
                          TextSpan(
                            text: "email_password_reset_link_subtitle.3".tr(),
                            style: Utilities.fonts.body(
                              backgroundColor: Constants.colors.tertiary,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = sendResetLink,
                          ),
                        ],
                      ),
                      style: Utilities.fonts.body(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 36.0),
              child: Wrap(
                spacing: 32.0,
                runSpacing: 12.0,
                children: [
                  DarkTextButton.large(
                    onPressed: () => context.beamToNamed(HomeLocation.route),
                    child: Opacity(
                      opacity: 0.8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Icon(UniconsLine.home, size: 20),
                          ),
                          Text(
                            "home".tr(),
                            style: Utilities.fonts.body2(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    backgroundColor: Colors.black12,
                  ),
                  DarkTextButton.large(
                    child: Opacity(
                      opacity: 0.8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "signin".tr(),
                            style: Utilities.fonts.body2(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child:
                                Icon(UniconsLine.arrow_circle_right, size: 20),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () => context.beamToNamed(SigninLocation.route),
                    backgroundColor: Colors.black12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget idleContainer() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 40.0,
          right: 40.0,
          top: 200.0,
          bottom: 100.0,
        ),
        child: Column(
          children: <Widget>[
            header(),
            emailInput(),
            validationButton(),
          ],
        ),
      ),
    );
  }

  Widget emailInput() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: Container(
        width: 400.0,
        padding: EdgeInsets.only(top: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            OutlinedTextField(
              autofocus: true,
              label: "email".tr(),
              hintText: "iamanartist@art.com",
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                _email = value;
              },
              onSubmitted: (value) => sendResetLink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeInX(
          beginX: 10.0,
          delay: 100.milliseconds,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 20.0,
            ),
            child: IconButton(
              tooltip: "back".tr(),
              onPressed: () => Utilities.navigation.back(context),
              icon: Icon(UniconsLine.arrow_left),
            ),
          ),
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FadeInY(
                beginY: 50.0,
                child: Text(
                  "password_forgot".tr(),
                  textAlign: TextAlign.center,
                  style: Utilities.fonts.body(
                    fontSize: 26.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FadeInY(
                beginY: 50.0,
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    "password_forgot_reset_process".tr(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: Utilities.fonts.body(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget validationButton() {
    return FadeInY(
      delay: 200.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 42.0),
        child: DarkElevatedButton.large(
          onPressed: sendResetLink,
          child: Text(
            "password_reset_send_link".tr(),
            style: Utilities.fonts.body(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  bool inputValuesOk() {
    if (_email.isEmpty) {
      context.showErrorBar(
        content: Text("email_empty_no_valid".tr()),
      );

      return false;
    }

    if (!UsersActions.checkEmailFormat(_email)) {
      context.showErrorBar(
        content: Text("email_not_valid".tr()),
      );

      return false;
    }

    return true;
  }

  void sendResetLink() async {
    if (!inputValuesOk()) {
      return;
    }
    try {
      setState(() {
        _loading = true;
        _completed = false;
      });

      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);

      setState(() {
        _loading = false;
        _completed = true;
      });
    } catch (error) {
      Utilities.logger.e(error);

      setState(() => _loading = false);

      context.showErrorBar(
        content: Text("email_doesnt_exist".tr()),
      );
    }
  }
}
