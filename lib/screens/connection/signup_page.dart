import 'dart:async';

import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/sheet_header.dart';
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
import 'package:unicons/unicons.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  /// Currently checking email entered if true.
  bool _checkingEmail = false;

  /// Currently checking username entered if true.
  bool _checkingUsername = false;

  /// Trying to create an account if true.
  bool _creatingAccount = false;

  /// Confirm password. Should be the same as `_password`.
  String _confirmPassword = "";

  /// A hint if the confirm password doesn't match `_password` value.
  String _confirmPasswordHint = "";

  /// Chosen email.
  String _email = "";

  /// A hint if the chosen email is not correct or already taken.
  String _emailHint = "";

  /// Chosen password.
  String _password = "";

  /// A hint if the chosen password doesn't respect the right format.
  String _passwordHint = "";

  /// Chosen username.
  String _username = "";

  /// A hint if the chosen username doesn't respect the right format
  /// or is already taken.
  String _usernameHint = "";

  /// Timer to debounce email check.
  Timer? _emailTimer;

  /// Timer to debounce username check.
  Timer? _usernameTimer;

  @override
  void dispose() {
    _emailTimer?.cancel();
    _usernameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ApplicationBar(
            right: IconButton(
              onPressed: showArgumentsDialog,
              color: Theme.of(context).secondaryHeaderColor,
              icon: Icon(UniconsLine.question_circle),
              iconSize: 32.0,
              padding: EdgeInsets.zero,
            ),
          ),
          SignupPageBody(
            isMobileSize: isMobileSize,
            loading: _creatingAccount,
            checkingEmail: _checkingEmail,
            checkingUsername: _checkingUsername,
            onUsernameChanged: onUsernameChanged,
            onEmailChanged: onEmailChanged,
            onConfirmPasswordChanged: onConfirmPasswordChanged,
            onPasswordChanged: onPasswordChanged,
            tryCreateAccount: createAccount,
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
    setState(() => _creatingAccount = true);

    if (!await checkInputs()) {
      setState(() => _creatingAccount = false);
      return;
    }

    try {
      final createAccountResponse =
          await ref.read(AppState.userProvider.notifier).signUp(
                email: _email,
                username: _username,
                password: _password,
              );

      setState(() => _creatingAccount = false);

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
      setState(() => _creatingAccount = false);
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
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    Utilities.ui.showAdaptiveDialog(
      context,
      isMobileSize: isMobileSize,
      builder: (BuildContext context) {
        final Widget body = Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    "account_create_arguments.preview".tr() + ":",
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
        );

        if (isMobileSize) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SheetHeader(
                    title: "account_create".tr(),
                    subtitle: "account_create_why".tr(),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 24.0,
                    ),
                  ),
                  body,
                ],
              ),
            ),
          );
        }

        return ThemedDialog(
          onCancel: Beamer.of(context).popRoute,
          titleValue: "account_create_why".tr(),
          body: body,
          textButtonValidation: "thank_you_exclamation".tr(),
          onValidate: Beamer.of(context).popRoute,
        );
      },
    );
  }

  Widget textArgument(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 4.0),
            child: CircleAvatar(
              radius: 4.0,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
          Expanded(
            child: Opacity(
              opacity: 0.6,
              child: Text(
                text,
                style: Utilities.fonts.body(
                  fontWeight: FontWeight.w600,
                  fontSize: 20.0,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
