import 'package:artbooking/actions/users.dart';

import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/screens/connection/signin_page_body.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SigninPage extends ConsumerStatefulWidget {
  const SigninPage({
    Key? key,
    this.showBackButton = true,
  }) : super(key: key);

  /// Set to false if you want a custom behavior
  /// (e.g. when this page) is inside `AtelierPageWelcome`.
  final bool showBackButton;

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends ConsumerState<SigninPage> {
  /// If true, the app is connecting the user.
  bool _connecting = false;

  /// True if the current email value is valid.
  bool _emailValid = true;

  /// Typed user's email.
  String _email = "";

  /// Typed user's password.
  String _password = "";

  @override
  void dispose() {
    _email = "";
    _password = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          ApplicationBar(),
          SigninPageBody(
            connecting: _connecting,
            isMobileSize: isMobileSize,
            showBackButton: widget.showBackButton,
            onEmailChanged: onEmailChanged,
            onPasswordChanged: onPasswordChanged,
            tryConnect: tryConnect,
            emailValid: _emailValid,
          ),
        ],
      ),
    );
  }

  bool checkInputsFormat() {
    // ?NOTE: Triming because of TAB key on Desktop insert blank spaces.
    _email = _email.trim();
    _password = _password.trim();

    if (!UsersActions.checkEmailFormat(_email)) {
      context.showErrorBar(
        content: Text("email_not_valid".tr()),
      );

      return false;
    }

    if (_password.isEmpty) {
      context.showErrorBar(
        content: Text("password_empty_forbidden".tr()),
      );

      return false;
    }

    return true;
  }

  void tryConnect() async {
    if (!checkInputsFormat()) {
      return;
    }

    setState(() => _connecting = true);

    try {
      final userCred = await ref.read(AppState.userProvider.notifier).signIn(
            email: _email,
            password: _password,
          );

      if (userCred == null) {
        setState(() => _connecting = false);

        context.showErrorBar(
          content: Text("account_doesnt_exist".tr()),
        );

        return;
      }

      _connecting = false;
      context.beamToNamed(HomeLocation.route);
    } catch (error) {
      Utilities.logger.d(error);

      context.showErrorBar(
        content: Text("password_incorrect".tr()),
      );

      setState(() => _connecting = false);
    }
  }

  void onEmailChanged(String value) {
    _email = value.trim();

    setState(() {
      _emailValid = UsersActions.checkEmailFormat(_email);
    });
  }

  void onPasswordChanged(String value) {
    _password = value;
  }
}
