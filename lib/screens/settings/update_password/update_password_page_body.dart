import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/components/texts/outlined_text_field.dart';
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
    this.isMobileSize = false,
  }) : super(key: key);

  /// Password has been successfully updated if true.
  final bool completed;

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// Currently updating the current password if true.
  final bool updating;

  /// Y axis to start entrance animation.
  final double beginY;

  /// Callback to show tips about choosing a good password.
  final void Function()? onShowTipsDialog;

  /// Callback fired to update password.
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
                left: isMobileSize ? 12.0 : 25.0,
                right: isMobileSize ? 12.0 : 25.0,
                top: isMobileSize ? 36.0 : 80.0,
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
                      style: Utilities.fonts.body(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    "password_choosing_good_desc".tr(),
                    style: Utilities.fonts.body(
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              width: 400.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  OutlinedTextField(
                    autofocus: true,
                    controller: _currentPasswordController,
                    textInputAction: TextInputAction.next,
                    label: "password_current".tr(),
                    obscureText: true,
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
              padding: EdgeInsets.only(
                top: 20.0,
                bottom: 60.0,
                left: isMobileSize ? 16.0 : 40.0,
                right: isMobileSize ? 16.0 : 40.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  OutlinedTextField(
                    controller: _newPasswordController,
                    label: "password_new".tr(),
                    obscureText: true,
                    onSubmitted: (value) => onTryUpdatePassword?.call(
                      _currentPasswordController.text,
                      _newPasswordController.text,
                    ),
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
                style: Utilities.fonts.body(
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
