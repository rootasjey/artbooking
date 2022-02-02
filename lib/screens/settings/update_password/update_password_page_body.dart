import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/settings/update_password/update_password_page_completed.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:unicons/unicons.dart';

class UpdatePasswordPageBody extends StatelessWidget {
  const UpdatePasswordPageBody({
    Key? key,
    this.completed = false,
    this.updating = false,
    this.beginY = 0.0,
    this.onShowTipsDialog,
    this.onTryUpdatePassword,
  }) : super(key: key);

  final bool completed;
  final bool updating;
  final double beginY;
  final void Function()? onShowTipsDialog;
  final void Function(String, String)? onTryUpdatePassword;

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return UpdatePasswordPageCompleted();
    }

    if (updating) {
      return SliverToBoxAdapter(
        child: Center(
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
      );
    }

    final _newPasswordController = TextEditingController();
    final _currentPasswordController = TextEditingController();

    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          FadeInY(
            delay: 0.milliseconds,
            beginY: beginY,
            child: Container(
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
                  onTap: onShowTipsDialog,
                ),
              ),
            ),
          ),
          FadeInY(
            delay: 100.milliseconds,
            beginY: beginY,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              width: 400.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    autofocus: true,
                    controller: _currentPasswordController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      focusColor: Constants.colors.clairPink,
                      labelText: "password_current".tr(),
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                      ),
                    ),
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
            ),
          ),
          FadeInY(
            delay: 200.milliseconds,
            beginY: beginY,
            child: Container(
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
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      focusColor: Constants.colors.clairPink,
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
                    onFieldSubmitted: (value) => onTryUpdatePassword?.call(
                      _currentPasswordController.text,
                      _newPasswordController.text,
                    ),
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
          ),
          FadeInY(
            delay: 300.milliseconds,
            beginY: beginY,
            child: DarkElevatedButton.large(
              onPressed: () => onTryUpdatePassword?.call(
                _currentPasswordController.text,
                _newPasswordController.text,
              ),
              child: Text(
                "password_update".tr().toUpperCase(),
                style: Utilities.fonts.style(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 200.0),
          ),
        ],
      ),
    );
  }
}
