import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/components/texts/outlined_text_field.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/settings/update_username/update_username_page_complete.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:unicons/unicons.dart';

class UpdateUsernamePageBody extends StatelessWidget {
  const UpdateUsernamePageBody({
    Key? key,
    this.onShowTipsDialog,
    this.onTryUpdateUsername,
    required this.username,
    this.onChanged,
    required this.nameErrorMessage,
    this.checking = false,
    this.completed = false,
    this.updating = false,
    required this.newUsername,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// If true, checking the new usernam availability.
  final bool checking;

  /// If true, the username has successfully been updated.
  final bool completed;

  /// Currently updating the username if true.
  final bool updating;

  /// Callback fired to show tips on username.
  final void Function()? onShowTipsDialog;

  /// Callback fired to try to update the username.
  final void Function()? onTryUpdateUsername;

  /// Callback fired when the username value is updated.
  /// The chnage will trigger username availability.
  final void Function(String)? onChanged;

  /// Current username value.
  final String username;

  /// New username value.
  final String newUsername;

  /// Error message about the new username.
  final String nameErrorMessage;

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return UpdateUsernamePageComplete();
    }

    if (updating) {
      return SliverToBoxAdapter(
        child: Container(
          width: 400.0,
          padding: EdgeInsets.all(isMobileSize ? 12.0 : 90.0),
          child: Column(
            children: <Widget>[
              AnimatedAppIcon(),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                  "username_updating".tr(),
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

    final _usernameController = TextEditingController();
    _usernameController.text = newUsername;
    _usernameController.selection = TextSelection.fromPosition(
      TextPosition(offset: newUsername.length),
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(isMobileSize ? 12.0 : 90.0),
        child: Column(
          children: [
            FadeInY(
              beginY: 10.0,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 40.0,
                ),
                child: Card(
                  color: Constants.colors.clairPink,
                  elevation: 2.0,
                  child: InkWell(
                    child: Container(
                      width: 340.0,
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Icon(
                                  UniconsLine.space_key,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Opacity(
                                    opacity: 0.6,
                                    child: Text(
                                      "username_current".tr(),
                                      style: Utilities.fonts.body(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    username,
                                    style: Utilities.fonts.body(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: onShowTipsDialog,
                  ),
                ),
              ),
            ),
            FadeInY(
              beginY: 10.0,
              delay: 100.milliseconds,
              child: Container(
                width: 370.0,
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 40.0,
                ),
                child: Column(
                  children: <Widget>[
                    OutlinedTextField(
                      autofocus: true,
                      controller: _usernameController,
                      label: "username_new".tr(),
                      keyboardType: TextInputType.text,
                      onChanged: onChanged,
                    ),
                    Opacity(
                      opacity: checking ? 1.0 : 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: LinearProgressIndicator(),
                      ),
                    ),
                    Opacity(
                      opacity: nameErrorMessage.isEmpty ? 0.0 : 1.0,
                      child: Text(
                        nameErrorMessage,
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
              beginY: 10.0,
              delay: 200.milliseconds,
              child: ElevatedButton(
                onPressed: onTryUpdateUsername,
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
                          "username_update".tr().toUpperCase(),
                          style: Utilities.fonts.body(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
