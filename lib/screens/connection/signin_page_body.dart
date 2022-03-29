import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/buttons/dark_text_button.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/texts/outlined_text_field.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/forgot_password_location.dart';
import 'package:artbooking/router/locations/signup_location.dart';
import 'package:artbooking/screens/connection/signin_page_header.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unicons/unicons.dart';

class SigninPageBody extends StatefulWidget {
  const SigninPageBody({
    Key? key,
    this.connecting = false,
    this.trySignin,
    this.onEmailChanged,
    this.onPasswordChanged,
    this.validEmail = true,
  }) : super(key: key);

  final bool connecting;
  final bool validEmail;
  final void Function()? trySignin;
  final void Function(String)? onEmailChanged;
  final void Function(String)? onPasswordChanged;

  @override
  State<SigninPageBody> createState() => _SigninPageBodyState();
}

class _SigninPageBodyState extends State<SigninPageBody> {
  final _passwordNode = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.connecting) {
      return SliverPadding(
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
                  child: LoadingView(
                    sliver: false,
                    title: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Opacity(
                        opacity: 0.6,
                        child: Text("signin_dot".tr()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      );
    }

    final child = Column(
      children: <Widget>[
        Stack(
          children: [
            Positioned(
              top: 0.0,
              right: 0.0,
              child: Lottie.asset(
                "assets/animations/waves.json",
                width: 200.0,
                height: 200.0,
              ),
            ),
            SizedBox(
              width: 320.0,
              child: Column(
                children: <Widget>[
                  SigninPageHeader(),
                  FadeInY(
                    delay: Duration(milliseconds: 50),
                    beginY: 50.0,
                    child: Padding(
                      padding: EdgeInsets.only(top: 80.0),
                      child: OutlinedTextField(
                        label: "email".tr().toUpperCase(),
                        controller: _emailController,
                        hintText: "awesomeartist@example.com",
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: widget.onEmailChanged,
                        onSubmitted: (value) => _passwordNode.requestFocus(),
                      ),
                    ),
                  ),
                  if (!widget.validEmail)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "email_enter_valid".tr(),
                          style: Utilities.fonts.style(
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                      ),
                    ),
                  FadeInY(
                    delay: Duration(milliseconds: 100),
                    beginY: 50.0,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: OutlinedTextField(
                        obscureText: true,
                        focusNode: _passwordNode,
                        label: "password".tr().toUpperCase(),
                        hintText: "•••",
                        controller: _passwordController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: widget.onPasswordChanged,
                        onSubmitted: (value) => widget.trySignin?.call(),
                      ),
                    ),
                  ),
                  FadeInY(
                    delay: Duration(milliseconds: 100),
                    beginY: 50.0,
                    child: DarkTextButton(
                      onPressed: () =>
                          context.beamToNamed(ForgotPasswordLocation.route),
                      child: Opacity(
                        opacity: 0.6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "password_forgot".tr(),
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  DarkElevatedButton.large(
                    margin: const EdgeInsets.only(top: 30.0),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "signin".tr().toUpperCase(),
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
                  FadeInY(
                    delay: Duration(milliseconds: 400),
                    beginY: 50.0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: DarkTextButton(
                        onPressed: () =>
                            context.beamToNamed(SignupLocation.route),
                        child: Opacity(
                          opacity: 0.6,
                          child: Text(
                            "dont_own_account".tr(),
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color:
                                  Theme.of(context).textTheme.bodyText2?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          child,
        ]),
      ),
    );
  }
}
