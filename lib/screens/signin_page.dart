import 'package:artbooking/actions/users.dart';

import 'package:artbooking/components/fade_in_x.dart';
import 'package:artbooking/components/fade_in_y.dart';
import 'package:artbooking/components/loading_animation.dart';
import 'package:artbooking/components/main_app_bar/main_app_bar.dart';
import 'package:artbooking/router/locations/forgot_password_location.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/locations/signup_location.dart';
import 'package:artbooking/types/globals/globals.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class SigninPage extends StatefulWidget {
  final void Function(bool isAuthenticated)? onSigninResult;

  const SigninPage({Key? key, this.onSigninResult}) : super(key: key);

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  bool _isConnecting = false;
  String _email = '';

  final _passwordNode = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _password = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          MainAppBar(),
          SliverPadding(
            padding: const EdgeInsets.only(
              top: 100.0,
              bottom: 300.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                Column(
                  children: <Widget>[
                    SizedBox(
                      width: 320.0,
                      child: body(),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (_isConnecting) {
      return LoadingAnimation(
        textTitle: "signin_dot".tr(),
      );
    }

    return idleContainer();
  }

  Widget idleContainer() {
    return Column(
      children: <Widget>[
        header(),
        emailInput(),
        passwordInput(),
        forgotPassword(),
        validationButton(),
        noAccountButton(),
      ],
    );
  }

  Widget emailInput() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(
          top: 80.0,
          left: 15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              autofocus: true,
              controller: _emailController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                icon: Icon(Icons.email),
                labelText: "email".tr(),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                _email = value;
              },
              onFieldSubmitted: (value) => _passwordNode.requestFocus(),
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

  Widget forgotPassword() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: TextButton(
        onPressed: () {
          context.beamToNamed(ForgotPasswordLocation.route);
        },
        child: Opacity(
          opacity: 0.6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                "password_forgot".tr(),
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FadeInX(
          beginX: 10.0,
          delay: 200.milliseconds,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 20.0,
            ),
            child: IconButton(
              onPressed: Beamer.of(context).popRoute,
              icon: Icon(UniconsLine.arrow_left),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FadeInY(
              beginY: 50.0,
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "signin".tr(),
                  textAlign: TextAlign.center,
                  style: FontsUtils.mainStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            FadeInY(
              delay: 300.milliseconds,
              beginY: 50.0,
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  "signin_existing_account".tr(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget noAccountButton() {
    return FadeInY(
      delay: 400.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextButton(
            onPressed: () {
              context.beamToNamed(SignupLocation.route);
            },
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "dont_own_account".tr(),
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            )),
      ),
    );
  }

  Widget passwordInput() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(
          top: 30.0,
          left: 15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: _passwordNode,
              controller: _passwordController,
              decoration: InputDecoration(
                icon: Icon(Icons.lock_outline),
                labelText: 'Password',
              ),
              obscureText: true,
              onChanged: (value) {
                _password = value;
              },
              onFieldSubmitted: (value) => signInProcess(),
              validator: (value) {
                if (value!.isEmpty) {
                  return "password_empty_forbidden".tr();
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget validationButton() {
    return FadeInY(
      delay: 200.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: ElevatedButton(
          onPressed: () => signInProcess(),
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(7.0),
              ),
            ),
          ),
          child: Container(
            width: 250.0,
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "signin".tr().toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Icon(
                    UniconsLine.arrow_right,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool checkInputsFormat() {
    // ?NOTE: Triming because of TAB key on Desktop insert blank spaces.
    _email = _email.trim();
    _password = _password.trim();

    if (!UsersActions.checkEmailFormat(_email)) {
      Snack.e(
        context: context,
        message: "email_not_valid".tr(),
      );

      return false;
    }

    if (_password.isEmpty) {
      Snack.e(
        context: context,
        message: "password_empty_forbidden".tr(),
      );

      return false;
    }

    return true;
  }

  void signInProcess() async {
    if (!checkInputsFormat()) {
      return;
    }

    setState(() => _isConnecting = true);

    try {
      final userNotifier = Globals.state.getUserNotifier();
      final userCred = await userNotifier.signIn(
        email: _email,
        password: _password,
      );

      if (userCred == null) {
        setState(() => _isConnecting = false);

        Snack.e(
          context: context,
          message: "account_doesnt_exist".tr(),
        );

        return;
      }

      _isConnecting = false;

      context.beamToNamed(HomeLocation.route);
    } catch (error) {
      appLogger.d(error);

      Snack.e(
        context: context,
        message: "password_incorrect".tr(),
      );

      setState(() => _isConnecting = false);
    }
  }
}
