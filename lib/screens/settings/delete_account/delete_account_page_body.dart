import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/components/texts/outlined_text_field.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/settings/delete_account/delete_account_page_completed.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:unicons/unicons.dart';

class DeleteAccountPageBody extends StatelessWidget {
  const DeleteAccountPageBody({
    Key? key,
    this.completed = false,
    this.deleting = false,
    this.beginY = 0.0,
    this.onShowTipsDialog,
    this.onTryDeleteAccount,
    this.isMobileSize = false,
  }) : super(key: key);

  /// Last authenticated user's account has been successfully deleted if true;
  final bool completed;

  /// Currently deleting the authenticated user's account if true.
  final bool deleting;

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// Y axis to start entrance animation.
  final double beginY;

  /// Callback which show a popup about the consequences of this deletion.
  final void Function()? onShowTipsDialog;

  /// Callback fired to delete the last authenticated user's account.
  final void Function(String)? onTryDeleteAccount;

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return DeleteAccountPageCompleted();
    }

    if (deleting) {
      return SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.only(top: isMobileSize ? 24.0 : 100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedAppIcon(),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                  "account_deleting".tr() + "...",
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

    final _currentPasswordController = TextEditingController();

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobileSize ? 12.0 : 40.0),
        child: Column(
          children: <Widget>[
            FadeInY(
              delay: 0.milliseconds,
              beginY: beginY,
              child: Container(
                width: 350.0,
                padding: EdgeInsets.only(
                  top: 60.0,
                  bottom: 40.0,
                ),
                child: Card(
                  color: Constants.colors.clairPink,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 16.0,
                    ),
                    title: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Icon(
                            UniconsLine.exclamation_triangle,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "are_you_sure".tr(),
                                style: Utilities.fonts.body(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                ),
                              ),
                              Opacity(
                                opacity: 0.6,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 0.0),
                                  child: Text(
                                    "action_irreversible".tr(),
                                    style: Utilities.fonts.body(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                width: 340.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    OutlinedTextField(
                      autofocus: true,
                      obscureText: true,
                      controller: _currentPasswordController,
                      label: "password_enter".tr(),
                      onSubmitted: onTryDeleteAccount,
                    ),
                  ],
                ),
              ),
            ),
            FadeInY(
              delay: 200.milliseconds,
              beginY: beginY,
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: DarkElevatedButton.large(
                  onPressed: () => onTryDeleteAccount?.call(
                    _currentPasswordController.text,
                  ),
                  child: Text(
                    "account_delete".tr().toUpperCase(),
                    style: Utilities.fonts.body(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 200.0),
            ),
          ],
        ),
      ),
    );
  }
}
