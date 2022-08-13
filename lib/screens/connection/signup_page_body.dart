import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/buttons/dark_text_button.dart';
import 'package:artbooking/components/texts/outlined_text_field.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/signin_location.dart';
import 'package:artbooking/screens/connection/connection_page_header.dart';
import 'package:artbooking/screens/connection/signup_page_loading.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unicons/unicons.dart';

class SignupPageBody extends StatefulWidget {
  const SignupPageBody({
    Key? key,
    this.loading = false,
    this.onEmailChanged,
    this.checkingEmail = false,
    this.emailErrorMessage = "",
    this.checkingUsername = false,
    this.onPasswordChanged,
    this.onConfirmPasswordChanged,
    this.usernameHint = "",
    this.onUsernameChanged,
    this.tryCreateAccount,
    this.confirmPasswordHint = "",
    this.passwordHint = "",
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  /// True if the user account is being created. False otherwise.
  final bool loading;

  /// True if the app is checking email format & availability.
  final bool checkingEmail;

  /// True if the app is checking username format & availability.
  final bool checkingUsername;

  /// Callback fired when email input has changed (to check format).
  final void Function(String value)? onEmailChanged;

  /// Callback fired when username input has changed (to check format).
  final void Function(String value)? onUsernameChanged;

  /// Callback fired when password input has changed (to check format).
  final void Function(String value)? onPasswordChanged;

  /// Callback fired when confirm password input has changed (to check equality).
  final void Function(String value)? onConfirmPasswordChanged;

  /// Callback fired to try to create a new user account.
  final void Function()? tryCreateAccount;

  /// Hint message about the current email typed.
  /// Provide suggestions and errors.
  final String emailErrorMessage;

  /// Hint message about the current username typed.
  /// Provide suggestions and errors.
  final String usernameHint;

  /// Hint message about the current password confirmation typed.
  /// Provide suggestions and errors.
  final String confirmPasswordHint;

  /// Hint message about the current password typed.
  /// Provide suggestions and errors.
  final String passwordHint;

  @override
  State<SignupPageBody> createState() => _SignupPageBodyState();
}

class _SignupPageBodyState extends State<SignupPageBody> {
  final _confirmPasswordNode = FocusNode();
  final _passwordNode = FocusNode();
  final _emailNode = FocusNode();

  @override
  void dispose() {
    _confirmPasswordNode.dispose();
    _passwordNode.dispose();
    _emailNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return SignupPageLoading();
    }

    return SliverPadding(
      padding: widget.isMobileSize
          ? const EdgeInsets.only(
              top: 0.0,
              bottom: 150.0,
              left: 12.0,
              right: 12.0,
            )
          : const EdgeInsets.only(
              top: 140.0,
              bottom: 300.0,
            ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            children: <Widget>[
              Stack(
                children: [
                  Positioned(
                    child: Lottie.asset(
                      "assets/animations/particles.json",
                      animate: false,
                      width: 400.0,
                      height: 600.0,
                    ),
                  ),
                  SizedBox(
                    width: 416.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ConnectionPageHeader(
                          title: "signup".tr(),
                          subtitle: "account_create_new".tr(),
                          showBackButton: !widget.isMobileSize,
                        ),
                        FadeInY(
                          delay: Duration(milliseconds: 0),
                          beginY: 50.0,
                          child: Padding(
                            padding: EdgeInsets.only(top: 60.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                OutlinedTextField(
                                    label: "username".tr().toUpperCase(),
                                    hintText: "Awesome Artist",
                                    textInputAction: TextInputAction.next,
                                    onChanged: widget.onUsernameChanged,
                                    onSubmitted: (_) =>
                                        _emailNode.requestFocus()),
                                if (widget.checkingUsername)
                                  LinearProgressIndicator(),
                                if (widget.usernameHint.isNotEmpty)
                                  Text(
                                    widget.usernameHint,
                                    style: Utilities.fonts.body(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        FadeInY(
                          beginY: 50.0,
                          delay: Duration(milliseconds: 100),
                          child: Padding(
                            padding: EdgeInsets.only(top: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                OutlinedTextField(
                                  focusNode: _emailNode,
                                  label: "email".tr().toUpperCase(),
                                  hintText: "awesomeartist@example.com",
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: widget.onEmailChanged,
                                  onSubmitted: (value) =>
                                      _passwordNode.requestFocus(),
                                ),
                                if (widget.checkingEmail)
                                  LinearProgressIndicator(),
                                if (widget.emailErrorMessage.isNotEmpty)
                                  Text(
                                    widget.emailErrorMessage,
                                    style: Utilities.fonts.body(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: [
                              FadeInY(
                                delay: Duration(milliseconds: 200),
                                beginY: 50.0,
                                child: SizedBox(
                                  width: widget.isMobileSize ? null : 200.0,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      OutlinedTextField(
                                        obscureText: true,
                                        focusNode: _passwordNode,
                                        label: "password".tr().toUpperCase(),
                                        textInputAction: TextInputAction.next,
                                        onChanged: widget.onPasswordChanged,
                                        onSubmitted: (_) =>
                                            _confirmPasswordNode.requestFocus(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              FadeInY(
                                delay: Duration(milliseconds: 400),
                                beginY: 50.0,
                                child: Container(
                                  width: widget.isMobileSize ? null : 200.0,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      OutlinedTextField(
                                        obscureText: true,
                                        focusNode: _confirmPasswordNode,
                                        label: "password_confirm"
                                            .tr()
                                            .toUpperCase(),
                                        textInputAction: TextInputAction.next,
                                        onChanged:
                                            widget.onConfirmPasswordChanged,
                                        onSubmitted: (value) =>
                                            widget.tryCreateAccount?.call(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (widget.passwordHint.isNotEmpty)
                                Text(
                                  widget.passwordHint,
                                  style: Utilities.fonts.body(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                              if (widget.confirmPasswordHint.isNotEmpty)
                                Text(
                                  widget.confirmPasswordHint,
                                  style: Utilities.fonts.body(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        FadeInY(
                          delay: Duration(milliseconds: 500),
                          beginY: 40.0,
                          child: Center(
                            child: DarkElevatedButton.large(
                              margin: const EdgeInsets.only(top: 40.0),
                              onPressed: widget.tryCreateAccount,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "account_create".tr().toUpperCase(),
                                    style: Utilities.fonts.body(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Icon(UniconsLine.arrow_right),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        FadeInY(
                          delay: Duration(milliseconds: 630),
                          beginY: 30.0,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                DarkTextButton(
                                  onPressed: () =>
                                      Beamer.of(context).beamToNamed(
                                    SigninLocation.route,
                                  ),
                                  child: Opacity(
                                    opacity: 0.6,
                                    child: Text(
                                      "account_already_own".tr(),
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
