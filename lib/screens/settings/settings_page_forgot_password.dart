import 'package:artbooking/actions/users.dart';
import 'package:artbooking/components/animations/fade_in_x.dart';
import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String email = '';

  bool isCompleted = false;
  bool isLoading = false;

  final passwordNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          ApplicationBar(),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 100.0,
                      bottom: 300.0,
                    ),
                    child: SizedBox(
                      width: 320,
                      child: body(),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isCompleted) {
      return completedContainer();
    }

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: LoadingView(
          title: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Opacity(
              opacity: 0.6,
              child: Text("email_sending".tr()),
            ),
          ),
        ),
      );
    }

    return idleContainer();
  }

  Widget completedContainer() {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Icon(
            Icons.check_circle,
            size: 80.0,
            color: Colors.green,
          ),
        ),
        Container(
          width: width > 400.0 ? 320.0 : 280.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
                child: Text(
                  "email_password_reset_link".tr(),
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              Opacity(
                opacity: .6,
                child: Text("email_check_spam".tr()),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 55.0,
          ),
          child: TextButton(
            onPressed: () {
              context.beamToNamed(HomeLocation.route);
            },
            child: Opacity(
              opacity: .6,
              child: Text(
                'Return to home',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget idleContainer() {
    return Column(
      children: <Widget>[
        header(),
        emailInput(),
        validationButton(),
      ],
    );
  }

  Widget emailInput() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              autofocus: true,
              decoration: InputDecoration(
                icon: Icon(UniconsLine.envelope),
                labelText: "email".tr(),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                email = value;
              },
              onFieldSubmitted: (value) => sendResetLink(),
              validator: (value) {
                if (value!.isEmpty) {
                  return "email_empty_forbidden".tr();
                }

                return null;
              },
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
              onPressed: Beamer.of(context).popBeamLocation,
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
                  style: Utilities.fonts.style(
                    fontSize: 25.0,
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
                    style: Utilities.fonts.style(
                      fontWeight: FontWeight.w400,
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
        padding: const EdgeInsets.only(top: 80.0),
        child: ElevatedButton(
          onPressed: sendResetLink,
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).primaryColor,
            textStyle: TextStyle(
              color: Colors.white,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("link_send".tr().toUpperCase()),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Icon(UniconsLine.envelope_send),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool inputValuesOk() {
    if (email.isEmpty) {
      Utilities.snack.e(
        context: context,
        message: "email_empty_no_valid".tr(),
      );

      return false;
    }

    if (!UsersActions.checkEmailFormat(email)) {
      Utilities.snack.e(
        context: context,
        message: "email_not_valid".tr(),
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
        isLoading = true;
        isCompleted = false;
      });

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() {
        isLoading = false;
        isCompleted = true;
      });
    } catch (error) {
      Utilities.logger.e(error);

      setState(() => isLoading = false);

      Utilities.snack.e(
        context: context,
        message: "email_doesnt_exist".tr(),
      );
    }
  }
}