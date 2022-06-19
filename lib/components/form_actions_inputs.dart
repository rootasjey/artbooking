import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// Use as a form footer to cancel of validate data.
class FormActionInputs extends StatelessWidget {
  /// Executed when the form is closed with the cancel button.
  final VoidCallback? onCancel;

  /// Executed when the form is closed with validate button.
  final VoidCallback? onValidate;

  /// Cancel button's text string value.
  final String cancelTextString;

  /// Save button's text string value.
  final String saveTextString;

  /// Padding around the buttons.
  final EdgeInsets padding;

  /// Automatically adjust padding according to app's widget.
  final bool adaptivePadding;

  const FormActionInputs({
    Key? key,
    this.onCancel,
    this.onValidate,
    this.cancelTextString = "Clear input",
    this.saveTextString = "Save",
    this.padding = const EdgeInsets.only(top: 20.0),
    this.adaptivePadding = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double left = 40.0;
    double spacing = 24.0;

    EdgeInsets localPadding = padding;
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    if (adaptivePadding && isMobileSize) {
      spacing = 12.0;
      left = 0.0;

      localPadding = EdgeInsets.only(
        top: 20.0,
        left: left,
      );
    }

    return Padding(
      padding: localPadding,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: spacing,
        runSpacing: 10.0,
        children: [
          Opacity(
            opacity: 0.6,
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: Icon(UniconsLine.times),
              label: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 12.0,
                ),
                child: Text(
                  cancelTextString,
                ),
              ),
              style: OutlinedButton.styleFrom(
                primary: Theme.of(context).textTheme.bodyText1?.color,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onValidate,
            icon: Icon(UniconsLine.check),
            label: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 12.0,
              ),
              child: Text(saveTextString),
            ),
            style: ElevatedButton.styleFrom(
              primary: Constants.colors.validation,
            ),
          ),
        ],
      ),
    );
  }
}
