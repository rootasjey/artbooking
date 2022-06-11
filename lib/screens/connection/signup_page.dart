import 'dart:async';

import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/screens/connection/signup_page_body.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:artbooking/actions/users.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supercharged/supercharged.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  bool _checkingEmail = false;
  bool _checkingUsername = false;
  bool _loading = false;

  String _confirmPassword = "";
  String _confirmPasswordHint = "";
  String _email = "";
  String _emailHint = "";
  String _password = "";
  String _passwordHint = "";
  String _username = "";
  String _usernameHint = "";

  Timer? _emailTimer;
  Timer? _usernameTimer;

  @override
  void dispose() {
    _emailTimer?.cancel();
    _usernameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showArgumentsDialog,
        label: Text(
          "why".tr().toLowerCase(),
          style: Utilities.fonts.body(
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          ApplicationBar(),
          SignupPageBody(
            loading: _loading,
            checkingEmail: _checkingEmail,
            checkingUsername: _checkingUsername,
            onUsernameChanged: onUsernameChanged,
            onEmailChanged: onEmailChanged,
            onConfirmPasswordChanged: onConfirmPasswordChanged,
            onPasswordChanged: onPasswordChanged,
            createAccount: createAccount,
            usernameHint: _usernameHint,
            emailErrorMessage: _emailHint,
            confirmPasswordHint: _confirmPasswordHint,
            passwordHint: _passwordHint,
          ),
        ],
      ),
    );
  }

  Future<bool> checkInputs() async {
    if (!checkInputsFormat()) {
      return false;
    }

    if (!await checkInputsAvailability()) {
      return false;
    }

    return true;
  }

  void createAccount() async {
    setState(() => _loading = true);

    if (!await checkInputs()) {
      setState(() => _loading = false);
      return;
    }

    try {
      final createAccountResponse =
          await ref.read(AppState.userProvider.notifier).signUp(
                email: _email,
                username: _username,
                password: _password,
              );

      setState(() => _loading = false);

      if (createAccountResponse.success) {
        Beamer.of(context).beamToNamed(HomeLocation.route);
        return;
      }

      String message = "account_create_error".tr();
      final error = createAccountResponse.error;

      if (error != null) {
        message = "[code: ${error.code}] - ${error.message}";
      }

      context.showErrorBar(content: Text(message));
    } catch (error) {
      Utilities.logger.e(error);
      setState(() => _loading = false);
      context.showErrorBar(
        content: Text("account_create_error".tr()),
      );
    }
  }

  Future<bool> checkInputsAvailability() async {
    final isEmailOk = await (UsersActions.checkEmailAvailability(_email));
    final isNameOk = await UsersActions.checkUsernameAvailability(_username);
    return isEmailOk && isNameOk;
  }

  bool checkInputsFormat() {
    // ?NOTE: Triming because of TAB key on Desktop insert blank spaces.
    _email = _email.trim();
    _password = _password.trim();

    if (_password.isEmpty || _confirmPassword.isEmpty) {
      context.showErrorBar(
        content: Text("password_empty_forbidden".tr()),
      );

      return false;
    }

    if (_confirmPassword != _password) {
      context.showErrorBar(
        content: Text("passwords_dont_match".tr()),
      );

      return false;
    }

    if (_username.isEmpty) {
      context.showErrorBar(
        content: Text("name_empty_forbidden".tr()),
      );

      return false;
    }

    if (!UsersActions.checkEmailFormat(_email)) {
      context.showErrorBar(
        content: Text("email_not_valid".tr()),
      );

      return false;
    }

    if (!UsersActions.checkUsernameFormat(_username)) {
      context.showErrorBar(
        content: Text(_username.length < 3
            ? "input_minimum_char".tr()
            : "input_valid_format".tr()),
      );

      return false;
    }

    return true;
  }

  void onConfirmPasswordChanged(String value) {
    _confirmPassword = value;

    if (_confirmPassword.isEmpty) {
      _confirmPasswordHint = "password_confirm_empty_forbidden".tr();
    } else if (_confirmPassword != _password) {
      _confirmPasswordHint = "passwords_dont_match".tr();
    } else {
      _confirmPasswordHint = "";
    }

    setState(() {});
  }

  void onEmailChanged(String value) async {
    _email = value.trim();

    final isWellFormatted = UsersActions.checkEmailFormat(_email);

    if (!isWellFormatted) {
      setState(() {
        _emailHint = "email_not_valid".tr();
      });

      return;
    }

    setState(() {
      _checkingEmail = true;
      _emailHint = "";
    });

    if (_emailTimer != null) {
      _emailTimer?.cancel();
      _emailTimer = null;
    }

    _emailTimer = Timer(1.seconds, () async {
      final isAvailable = await UsersActions.checkEmailAvailability(
        _email,
      );

      setState(() {
        _checkingEmail = false;
        _emailHint = isAvailable ? "" : "email_not_available".tr();
      });
    });
  }

  void onPasswordChanged(String value) {
    _password = value.trim();

    if (_password.isEmpty) {
      _passwordHint = "password_empty_forbidden".tr();
    } else {
      _passwordHint = "";
    }
  }

  void onUsernameChanged(String value) async {
    _username = value.trim();

    final isWellFormatted = UsersActions.checkUsernameFormat(_username);

    if (!isWellFormatted) {
      setState(() {
        _usernameHint = _username.length < 3
            ? "input_minimum_char".tr()
            : "input_valid_format".tr();
      });

      return;
    }

    setState(() {
      _checkingUsername = true;
      _usernameHint = "";
    });

    if (_usernameTimer != null) {
      _usernameTimer?.cancel();
      _usernameTimer = null;
    }

    _usernameTimer = Timer(1.seconds, () async {
      final isAvailable = await UsersActions.checkUsernameAvailability(
        _username,
      );

      setState(() {
        _checkingUsername = false;
        _usernameHint = isAvailable ? "" : "name_unavailable".tr();
      });
    });
  }

  void showArgumentsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          onCancel: Beamer.of(context).popRoute,
          titleValue: "account_create_why".tr(),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      "account_create_arguments.preview".tr(),
                      style: Utilities.fonts.body(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                textArgument("account_create_arguments.community".tr()),
                textArgument("account_create_arguments.create_book".tr()),
                textArgument("account_create_arguments.profile_page".tr()),
                textArgument("account_create_arguments.stats".tr()),
                textArgument(
                  "account_create_arguments.upload_illustration".tr(),
                ),
              ],
            ),
          ),
          textButtonValidation: "thank_you_exclamation".tr(),
          onValidate: Beamer.of(context).popRoute,
        );
      },
    );
  }

  Widget textArgument(String text) {
    final Color color = Colors.amber;

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CircleAvatar(radius: 4.0, backgroundColor: color),
        ),
        Text(
          text,
          style: Utilities.fonts.body(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
