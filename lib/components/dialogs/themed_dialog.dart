import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/buttons/dot_close_button.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/components/validation_shortcuts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A dialog with the theme of the app.
class ThemedDialog extends StatelessWidget {
  const ThemedDialog({
    Key? key,
    this.onCancel,
    required this.title,
    required this.body,
    required this.textButtonValidation,
    this.onValidate,
    this.focusNode,
    this.centerTitle = true,
    this.spaceActive = true,
    this.autofocus = true,
  }) : super(key: key);

  /// Trigger when the user tap on close button
  /// or fires keyboard shortcuts for closing the dialog.
  final Function()? onCancel;

  /// Trigger when the user tap on validation button
  /// or fires keyboard shortcuts for validating the dialog.
  final Function()? onValidate;

  /// Supply a [focusNode] parameter to force focus request
  /// if it doesn't automatically works.
  final FocusNode? focusNode;

  /// Will be displayed on validation button.
  final String textButtonValidation;

  /// Dialog's title.
  final Widget title;

  /// Dialog body. Can be a [SingleChildScrollView] for example.
  final Widget body;

  /// If true, center dialog's title.
  final bool centerTitle;

  /// If true, space bar will submit this dialog (as well as 'enter').
  final bool spaceActive;

  /// If true, this dialog will try to request focus on load.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ValidationShortcuts(
      autofocus: autofocus,
      focusNode: focusNode,
      onCancel: onCancel,
      onValidate: onValidate,
      spaceActive: spaceActive,
      child: SimpleDialog(
        backgroundColor: Constants.colors.clairPink,
        title: titleContainer(
          color: Theme.of(context).secondaryHeaderColor,
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.all(16.0),
        children: [
          body,
          footerButtons(),
        ],
      ),
    );
  }

  Widget closeButton() {
    return Positioned(
      top: 12.0,
      left: 12.0,
      child: DotCloseButton(
        tooltip: "cancel".tr(),
        onTap: onCancel,
      ),
    );
  }

  Widget footerButtons() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: DarkElevatedButton.large(
        onPressed: onValidate,
        child: Text(textButtonValidation),
      ),
    );
  }

  Widget titleContainer({required Color color}) {
    return Stack(
      children: [
        closeButton(),
        Column(
          crossAxisAlignment: centerTitle
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 32.0,
                right: 24.0,
              ),
              child: title,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Divider(
                thickness: 1.5,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}