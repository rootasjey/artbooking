import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
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
  }) : super(key: key);

  final void Function()? onShowTipsDialog;
  final void Function()? onTryUpdateUsername;
  final void Function(String)? onChanged;
  final String username;
  final String newUsername;
  final String nameErrorMessage;
  final bool checking;
  final bool completed;
  final bool updating;

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return UpdateUsernamePageComplete();
    }

    if (updating) {
      return SliverToBoxAdapter(
        child: Container(
          width: 400.0,
          padding: const EdgeInsets.all(90.0),
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
        padding: const EdgeInsets.all(90.0),
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
                                      style: Utilities.fonts.style(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    username,
                                    style: Utilities.fonts.style(
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
                    TextFormField(
                      autofocus: true,
                      controller: _usernameController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        focusColor: Constants.colors.clairPink,
                        labelText: "username_new".tr(),
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                      ),
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
                        style: Utilities.fonts.style(
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
                          style: Utilities.fonts.style(
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
