import 'dart:async';

import 'package:artbooking/actions/users.dart';
import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/components/fade_in_y.dart';
import 'package:artbooking/components/main_app_bar/main_app_bar.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/types/globals/globals.dart';
import 'package:artbooking/types/globals/app_state.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class UpdateEmailPage extends ConsumerStatefulWidget {
  @override
  _UpdateEmailPageState createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends ConsumerState<UpdateEmailPage> {
  bool _isCheckingEmail = false;
  bool _isUpdating = false;
  bool _isCompleted = false;

  final _beginY = 10.0;
  final _currentPasswordNode = FocusNode();
  final _newEmailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final Color _clairPink = Globals.constants.colors.clairPink;

  String _newEmailValue = '';
  String _emailInputErrorMessage = '';
  String _currentPasswordValue = '';

  Timer? _emailTimer;

  @override
  void dispose() {
    _currentPasswordNode.dispose();
    _newEmailController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String email =
        ref.watch(AppState.userProvider).firestoreUser?.email ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverEdgePadding(),
          MainAppBar(),
          header(),
          body(email: email),
        ],
      ),
    );
  }

  Widget body({required String email}) {
    if (_isCompleted) {
      return completedView();
    }

    if (_isUpdating) {
      return updatingView();
    }

    return idleView(email: email);
  }

  Widget idleView({required String email}) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 60.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(
            width: 400.0,
            child: Column(
              children: <Widget>[
                FadeInY(
                  delay: 0.milliseconds,
                  beginY: _beginY,
                  child: helperCard(email: email),
                ),
                FadeInY(
                  delay: 100.milliseconds,
                  beginY: _beginY,
                  child: emailInput(),
                ),
                FadeInY(
                  delay: 200.milliseconds,
                  beginY: _beginY,
                  child: passwordInput(),
                ),
                FadeInY(
                  delay: 300.milliseconds,
                  beginY: _beginY,
                  child: validationButton(),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 200.0),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget completedView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          width: 400.0,
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Icon(
                  Icons.check,
                  size: 80.0,
                  color: Colors.green,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 40.0),
                child: Text(
                  "email_update_successful".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: Beamer.of(context).popRoute,
                child: Text("back".tr()),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget header() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Opacity(
                      opacity: 0.8,
                      child: IconButton(
                        onPressed: Beamer.of(context).popRoute,
                        icon: Icon(UniconsLine.arrow_left),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 0.4,
                        child: Text(
                          "settings".tr().toUpperCase(),
                          style: FontsUtils.mainStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          "email_update".tr(),
                          style: FontsUtils.mainStyle(
                            fontSize: 50.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        width: 400.0,
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Opacity(
                          opacity: 0.5,
                          child: Text(
                            "email_update_description".tr(),
                            style: FontsUtils.mainStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget helperCard({required String email}) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 40.0,
      ),
      child: Card(
        color: Globals.constants.colors.clairPink,
        elevation: 2.0,
        child: InkWell(
          child: Container(
            width: 330.0,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(
                        UniconsLine.envelope,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Opacity(
                          opacity: 0.6,
                          child: Text(
                            "email_current".tr(),
                          ),
                        ),
                        Text(
                          email,
                          style: FontsUtils.mainStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () => showTipsDialog(email: email),
        ),
      ),
    );
  }

  Widget emailInput() {
    return Container(
      width: 390.0,
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autofocus: true,
            controller: _newEmailController,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _currentPasswordNode.requestFocus(),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              focusColor: _clairPink,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              labelText: "email_new".tr(),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) async {
              _newEmailValue = value;

              setState(() {
                _isCheckingEmail = true;
              });

              final isWellFormatted =
                  UsersActions.checkEmailFormat(_newEmailValue);

              if (!isWellFormatted) {
                setState(() {
                  _isCheckingEmail = false;
                  _emailInputErrorMessage = "email_not_valid".tr();
                });

                return;
              }

              _emailTimer?.cancel();
              _emailTimer = null;

              _emailTimer = Timer(1.seconds, () async {
                final isAvailable =
                    await (UsersActions.checkEmailAvailability(_newEmailValue));

                if (!isAvailable) {
                  setState(() {
                    _isCheckingEmail = false;
                    _emailInputErrorMessage = "email_not_available".tr();
                  });

                  return;
                }

                setState(() {
                  _isCheckingEmail = false;
                  _emailInputErrorMessage = '';
                });
              });
            },
            validator: (value) {
              if (value!.isEmpty) {
                return "email_empty_forbidden".tr();
              }

              return null;
            },
          ),
          if (_isCheckingEmail) emailProgress(),
          if (_emailInputErrorMessage.isNotEmpty) emailInputError(),
        ],
      ),
    );
  }

  Widget emailInputError() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 40.0,
      ),
      child: Text(_emailInputErrorMessage,
          style: TextStyle(
            color: Colors.red.shade300,
          )),
    );
  }

  Widget emailProgress() {
    return Container(
      padding: const EdgeInsets.only(
        left: 40.0,
      ),
      child: LinearProgressIndicator(),
    );
  }

  Widget passwordInput() {
    return Container(
      width: 390.0,
      padding: EdgeInsets.only(
        top: 20.0,
        bottom: 60.0,
        left: 30.0,
        right: 30.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            focusNode: _currentPasswordNode,
            controller: _currentPasswordController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              focusColor: _clairPink,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              labelText: "password_current".tr(),
            ),
            obscureText: true,
            onChanged: (value) {
              _currentPasswordValue = value;
            },
            onFieldSubmitted: (value) => tryUpdateEmail(),
            validator: (value) {
              if (value!.isEmpty) {
                return "password_empty_forbidden".tr();
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget updatingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        SizedBox(
          width: 400.0,
          child: Column(
            children: <Widget>[
              AnimatedAppIcon(),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                  "email_updating".tr(),
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }

  Widget validationButton() {
    return ElevatedButton(
      onPressed: tryUpdateEmail,
      style: ElevatedButton.styleFrom(
        primary: Colors.black87,
      ),
      child: SizedBox(
        width: 320.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                "email_update".tr().toUpperCase(),
                style: FontsUtils.mainStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> checkInputsAvailbility() async {
    return await UsersActions.checkEmailAvailability(_newEmailValue);
  }

  bool checkInputsFormat() {
    if (_newEmailValue.isEmpty) {
      Snack.e(
        context: context,
        message: "email_empty_forbidden".tr(),
      );

      return false;
    }

    if (_currentPasswordValue.isEmpty) {
      Snack.e(
        context: context,
        message: "password_empty_forbidden".tr(),
      );

      return false;
    }

    if (!UsersActions.checkEmailFormat(_newEmailValue)) {
      Snack.e(
        context: context,
        message: "email_not_validd".tr(),
      );

      return false;
    }

    return true;
  }

  void tryUpdateEmail() async {
    if (!checkInputsFormat()) {
      return;
    }

    setState(() => _isUpdating = true);

    try {
      if (!await checkInputsAvailbility()) {
        setState(() => _isUpdating = false);

        Snack.e(
          context: context,
          message: "email_not_available".tr(),
        );

        return;
      }

      final response =
          await ref.read(AppState.userProvider.notifier).updateEmail(
                newEmail: _newEmailValue,
                password: _currentPasswordValue,
              );

      if (!response.success) {
        throw ErrorDescription(response.error?.message ?? '');
      }

      setState(() {
        _isUpdating = false;
        _isCompleted = true;
      });
    } catch (error) {
      appLogger.e(error);
      setState(() => _isUpdating = false);

      Snack.e(
        context: context,
        message: "email_update_error".tr(),
      );
    }
  }

  void showTipsDialog({required String email}) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: _clairPink,
          title: Text(
            "email_current".tr(),
            style: FontsUtils.mainStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: <Widget>[
            Divider(
              color: Theme.of(context).secondaryHeaderColor,
              thickness: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  email,
                  style: FontsUtils.mainStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
