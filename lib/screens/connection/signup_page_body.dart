import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/buttons/dark_text_button.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/components/texts/outlined_text_field.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/signin_location.dart';
import 'package:artbooking/screens/connection/connection_page_header.dart';
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
    this.createAccount,
    this.confirmPasswordHint = "",
    this.passwordHint = "",
  }) : super(key: key);

  /// True if the user account is being created. False otherwise.
  final bool loading;

  /// True if the app is checking email format & availability.
  final bool checkingEmail;

  /// True if the app is checking username format & availability.
  final bool checkingUsername;

  final void Function(String value)? onEmailChanged;
  final void Function(String value)? onUsernameChanged;
  final void Function(String value)? onPasswordChanged;
  final void Function(String value)? onConfirmPasswordChanged;
  final void Function()? createAccount;

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
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0, bottom: 300.0),
          child: Column(
            children: [
              AnimatedAppIcon(
                textTitle: "account_creating".tr() + "...",
              ),
              Opacity(
                opacity: 0.8,
                child: AnimatedTextKit(
                  animatedTexts: [
                    animatedText("account_creating_subtitle.glad".tr()),
                    animatedText("account_creating_subtitle.draw".tr()),
                    animatedText("account_creating_subtitle.atelier".tr()),
                    animatedText("account_creating_subtitle.settings".tr()),
                    animatedText("account_creating_subtitle.duration".tr()),
                    animatedText("account_creating_subtitle.check".tr()),
                    animatedText("account_creating_subtitle.profile_page".tr()),
                    animatedText("account_creating_subtitle.masterpiece".tr()),
                  ],
                  isRepeatingAnimation: true,
                  repeatForever: true,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ConnectionPageHeader(
          title: "signup".tr(),
          subtitle: "account_create_new".tr(),
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
                    onSubmitted: (_) => _emailNode.requestFocus()),
                if (widget.checkingUsername) LinearProgressIndicator(),
                if (widget.usernameHint.isNotEmpty)
                  Text(
                    widget.usernameHint,
                    style: Utilities.fonts.style(
                      color: Theme.of(context).secondaryHeaderColor,
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
                  onSubmitted: (value) => _passwordNode.requestFocus(),
                ),
                if (widget.checkingEmail) LinearProgressIndicator(),
                if (widget.emailErrorMessage.isNotEmpty)
                  Text(
                    widget.emailErrorMessage,
                    style: Utilities.fonts.style(
                      color: Theme.of(context).secondaryHeaderColor,
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
                child: Container(
                  width: 200.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      OutlinedTextField(
                        obscureText: true,
                        focusNode: _passwordNode,
                        label: "password".tr().toUpperCase(),
                        textInputAction: TextInputAction.next,
                        onChanged: widget.onPasswordChanged,
                        onSubmitted: (_) => _confirmPasswordNode.requestFocus(),
                      ),
                    ],
                  ),
                ),
              ),
              FadeInY(
                delay: Duration(milliseconds: 400),
                beginY: 50.0,
                child: Container(
                  width: 200.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      OutlinedTextField(
                        obscureText: true,
                        focusNode: _confirmPasswordNode,
                        label: "password_confirm".tr().toUpperCase(),
                        textInputAction: TextInputAction.next,
                        onChanged: widget.onConfirmPasswordChanged,
                        onSubmitted: (value) => widget.createAccount?.call(),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.passwordHint.isNotEmpty)
                Text(
                  widget.passwordHint,
                  style: Utilities.fonts.style(
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
              if (widget.confirmPasswordHint.isNotEmpty)
                Text(
                  widget.confirmPasswordHint,
                  style: Utilities.fonts.style(
                    color: Theme.of(context).secondaryHeaderColor,
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
              onPressed: widget.createAccount,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "account_create".tr().toUpperCase(),
                    style: Utilities.fonts.style(
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
                  onPressed: () => Beamer.of(context).beamToNamed(
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
    );

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 100.0,
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
                      width: 400.0,
                      height: 600.0,
                    ),
                  ),
                  SizedBox(
                    width: 416.0,
                    child: child,
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }

  RotateAnimatedText animatedText(String text) {
    return RotateAnimatedText(
      text,
      duration: Duration(seconds: 5),
      textStyle: Utilities.fonts.style(
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
        height: 2,
        decoration: TextDecoration.underline,
        decorationColor: Colors.amber,
        decorationThickness: 2.0,
        decorationStyle: TextDecorationStyle.wavy,
      ),
    );
  }
}
