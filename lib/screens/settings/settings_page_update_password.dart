import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class SettingsPageUpdatePassword extends ConsumerStatefulWidget {
  @override
  _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState
    extends ConsumerState<SettingsPageUpdatePassword> {
  bool _isCompleted = false;
  bool _isUpdating = false;

  double _beginY = 10.0;

  final Color _clairPink = Constants.colors.clairPink;
  final _newPasswordNode = FocusNode();

  String _currentPassword = '';
  String _newPassword = '';

  @override
  void dispose() {
    _newPasswordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          ApplicationBar(),
          header(),
          body(),
        ],
      ),
    );
  }

  Widget body() {
    if (_isCompleted) {
      return completedView();
    }

    if (_isUpdating) {
      return updatingScreen();
    }

    return idleView();
  }

  Widget completedView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Icon(
                  UniconsLine.check,
                  color: Constants.colors.validation,
                  size: 80.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 0.0),
                child: Text(
                  "password_update_success".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget currentPasswordInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      width: 400.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              fillColor: Colors.white,
              focusColor: _clairPink,
              labelText: "password_current".tr(),
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
            ),
            onChanged: (value) {
              _currentPassword = value;
            },
            onFieldSubmitted: (_) => _newPasswordNode.requestFocus(),
            obscureText: true,
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
                          style: Utilities.fonts.style(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          "password_update".tr(),
                          style: Utilities.fonts.style(
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
                            "password_update_description".tr(),
                            style: Utilities.fonts.style(
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

  Widget helpCard() {
    return Container(
      padding: EdgeInsets.only(
        left: 25.0,
        right: 25.0,
        top: 80.0,
        bottom: 40.0,
      ),
      width: 378.0,
      child: Card(
        color: Constants.colors.clairPink,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading: Icon(UniconsLine.question),
          title: Opacity(
            opacity: 0.6,
            child: Text(
              "password_choosing_good".tr(),
              style: Utilities.fonts.style(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          subtitle: Text(
            "password_choosing_good_desc".tr(),
            style: Utilities.fonts.style(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: showTipsDialog,
        ),
      ),
    );
  }

  Widget idleView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Column(
          children: <Widget>[
            FadeInY(
              delay: 0.milliseconds,
              beginY: _beginY,
              child: helpCard(),
            ),
            FadeInY(
              delay: 100.milliseconds,
              beginY: _beginY,
              child: currentPasswordInput(),
            ),
            FadeInY(
              delay: 200.milliseconds,
              beginY: _beginY,
              child: newPasswordInput(),
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
      ]),
    );
  }

  Widget newPasswordInput() {
    return Container(
      width: 400.0,
      padding: const EdgeInsets.only(
        top: 20.0,
        bottom: 60.0,
        left: 40.0,
        right: 40.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            focusNode: _newPasswordNode,
            decoration: InputDecoration(
              fillColor: Colors.white,
              focusColor: _clairPink,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              labelText: "password_new".tr(),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2.0,
                ),
              ),
            ),
            obscureText: true,
            onChanged: (value) {
              _newPassword = value;
            },
            onFieldSubmitted: (value) => tryUpdatePassword(),
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

  Widget textTitle() {
    return Text(
      "password_update".tr(),
      style: TextStyle(
        fontSize: 35.0,
      ),
    );
  }

  Widget updatingScreen() {
    return SliverList(
        delegate: SliverChildListDelegate([
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedAppIcon(),
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                "password_updating".tr(),
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            )
          ],
        ),
      ),
    ]));
  }

  Widget validationButton() {
    return ElevatedButton(
      onPressed: tryUpdatePassword,
      style: ElevatedButton.styleFrom(
        primary: Colors.black87,
      ),
      child: SizedBox(
        width: 300.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                "password_update".tr().toUpperCase(),
                style: Utilities.fonts.style(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(UniconsLine.check),
          ],
        ),
      ),
    );
  }

  void tryUpdatePassword() async {
    if (!checkInputsFormat()) {
      return;
    }

    setState(() => _isUpdating = true);

    try {
      ref.read(AppState.userProvider.notifier).updatePassword(
            currentPassword: _currentPassword,
            newPassword: _newPassword,
          );

      setState(() {
        _isUpdating = false;
        _isCompleted = true;
      });
    } catch (error) {
      Utilities.logger.e(error);
      setState(() => _isUpdating = false);

      context.showErrorBar(
        content: Text("password_update_error".tr()),
      );
    }
  }

  bool checkInputsFormat() {
    if (_currentPassword.isEmpty) {
      context.showErrorBar(
        content: Text("password_empty_forbidden".tr()),
      );

      return false;
    }

    if (_newPassword.isEmpty) {
      context.showErrorBar(
        content: Text("password_empty_forbidden".tr()),
      );

      return false;
    }

    return true;
  }

  void showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: _clairPink,
          title: Text(
            "password_tips".tr(),
            style: Utilities.fonts.style(
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
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("password_tips_1".tr()),
                  Padding(padding: const EdgeInsets.only(top: 15.0)),
                  Text("password_tips_2".tr()),
                  Padding(padding: const EdgeInsets.only(top: 15.0)),
                  Text("password_tips_3".tr()),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
