import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/components/texts/outlined_text_field.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/settings/update_email/update_email_page_completed.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:unicons/unicons.dart';

class UpdateEmailPageBody extends StatelessWidget {
  const UpdateEmailPageBody({
    Key? key,
    this.completed = false,
    this.updating = false,
    required this.currentEmail,
    required this.newEmail,
    this.beginY = 0.0,
    this.onTryUpdateEmail,
    this.onShowTipsDialog,
    this.onChangedInput,
    this.checking = false,
    required this.errorMessage,
    this.isMobileSize = false,
  }) : super(key: key);

  /// Email has been successfully updated if true.
  final bool completed;

  /// Checking new email availability if true.
  final bool checking;

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// Currently updating with the new email if true.
  final bool updating;

  /// Current authenticated user's email.
  final String currentEmail;

  /// New email to replace the old one.
  final String newEmail;

  /// Error about the new email.
  final String errorMessage;

  /// Y axis to start entrance animation.
  final double beginY;

  /// Callback to show tips about choosing a good email.
  final void Function(String)? onShowTipsDialog;

  /// Callback fired when new email input has changed.
  final void Function(String)? onChangedInput;

  /// Callback fired to udpate user's email.
  final void Function(String)? onTryUpdateEmail;

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return UpdateEmailPageCompleted();
    }

    if (updating) {
      return SliverToBoxAdapter(
        child: SizedBox(
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
      );
    }

    final _newEmailController = TextEditingController();
    final _currentPasswordController = TextEditingController();

    _newEmailController.text = newEmail;
    _newEmailController.selection = TextSelection.fromPosition(
      TextPosition(offset: newEmail.length),
    );

    return SliverToBoxAdapter(
      child: Container(
        width: 400.0,
        padding: EdgeInsets.all(isMobileSize ? 12.0 : 60.0),
        child: Column(
          children: <Widget>[
            FadeInY(
              delay: 0.milliseconds,
              beginY: beginY,
              child: Padding(
                padding: EdgeInsets.only(
                  top: isMobileSize ? 36.0 : 0.0,
                  bottom: 40.0,
                ),
                child: Card(
                  color: Constants.colors.clairPink,
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
                                    currentEmail,
                                    style: Utilities.fonts.body(
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
                    onTap: () => onShowTipsDialog?.call(currentEmail),
                  ),
                ),
              ),
            ),
            FadeInY(
              delay: 100.milliseconds,
              beginY: beginY,
              child: Container(
                width: 390.0,
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    OutlinedTextField(
                      autofocus: true,
                      controller: _newEmailController,
                      textInputAction: TextInputAction.next,
                      label: "email_new".tr(),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: onChangedInput,
                    ),
                    Opacity(
                      opacity: checking ? 1.0 : 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: LinearProgressIndicator(),
                      ),
                    ),
                    Opacity(
                      opacity: errorMessage.isEmpty ? 0.0 : 1.0,
                      child: Text(
                        errorMessage,
                        style: Utilities.fonts.body(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeInY(
              delay: 200.milliseconds,
              beginY: beginY,
              child: Container(
                width: 390.0,
                padding: EdgeInsets.only(
                  top: isMobileSize ? 0.0 : 20.0,
                  bottom: 60.0,
                  left: 6.0,
                  right: 6.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    OutlinedTextField(
                      controller: _currentPasswordController,
                      label: "password_current".tr(),
                      obscureText: true,
                      onSubmitted: (passwordValue) {
                        onTryUpdateEmail?.call(passwordValue);
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
                onPressed: () {
                  onTryUpdateEmail?.call(_currentPasswordController.text);
                },
                child: Text(
                  "email_update".tr().toUpperCase(),
                  style: Utilities.fonts.body(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
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
