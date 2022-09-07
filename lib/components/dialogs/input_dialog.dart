import 'dart:math';

import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/texts/title_dialog.dart';
import 'package:artbooking/components/texts/outlined_text_field.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A dialog which has one or multiple inputs.
class InputDialog extends StatelessWidget {
  const InputDialog({
    Key? key,
    required this.onCancel,
    required this.onSubmitted,
    required this.subtitleValue,
    required this.titleValue,
    this.asBottomSheet = false,
    this.descriptionController,
    this.nameController,
    this.onNameChanged,
    this.onDescriptionChanged,
    this.submitButtonValue = "",
  }) : super(key: key);

  /// If true, this widget will take a suitable layout for bottom sheet.
  /// Otherwise, it will have a dialog layout.
  final bool asBottomSheet;

  /// Callback fired when name input value has changed.
  final void Function(String)? onNameChanged;

  /// Callback fired when description input value has changed.
  final void Function(String)? onDescriptionChanged;

  /// Callback fired when we validate inputs.
  final void Function(String) onSubmitted;

  /// Callback fired when we cancel and close the inputs.
  final void Function() onCancel;

  /// Text value for the submit button.
  final String submitButtonValue;

  /// Title value.
  final String titleValue;

  /// Subtitle value.
  final String subtitleValue;

  /// Controller for name input.
  final TextEditingController? nameController;

  /// Controller for description input.
  final TextEditingController? descriptionController;

  @override
  Widget build(BuildContext context) {
    if (asBottomSheet) {
      return mobileLayout();
    }

    return SimpleDialog(
      backgroundColor: Constants.colors.clairPink,
      title: header(),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16.0),
      children: [
        nameInput(),
        descriptionInput(),
        footerButtons(),
      ],
    );
  }

  Widget descriptionInput() {
    String hintText =
        "book_create_hint_description_texts.${Random().nextInt(12)}".tr();

    if (descriptionController != null &&
        descriptionController!.text.isNotEmpty) {
      hintText = descriptionController!.text;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 25.0,
      ),
      child: OutlinedTextField(
        label: "description".tr().toUpperCase(),
        controller: descriptionController,
        hintText: hintText,
        onChanged: onDescriptionChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }

  Widget footerButtons() {
    final String textValue =
        submitButtonValue.isNotEmpty ? submitButtonValue : "create".tr();

    return Padding(
      padding: EdgeInsets.all(24.0),
      child: DarkElevatedButton.large(
        onPressed: () {
          final String value = nameController?.text ?? '';
          onSubmitted.call(value);
        },
        child: Text(textValue),
      ),
    );
  }

  Widget header() {
    return TitleDialog(
      titleValue: titleValue,
      subtitleValue: subtitleValue,
      onCancel: onCancel,
    );
  }

  Widget mobileLayout() {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header(),
            nameInput(),
            descriptionInput(),
            footerButtons(),
          ],
        ),
      ),
    );
  }

  Widget nameInput() {
    String hintText = "book_create_hint_texts.${Random().nextInt(9)}".tr();

    if (nameController != null && nameController!.text.isNotEmpty) {
      hintText = nameController!.text;
    }

    return Padding(
      padding: EdgeInsets.all(26.0),
      child: OutlinedTextField(
        label: "title".tr().toUpperCase(),
        controller: nameController,
        hintText: hintText,
        onChanged: onNameChanged,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  static Widget singleInput({
    final Key? key,
    required final String titleValue,
    required final String subtitleValue,
    required final void Function() onCancel,
    final bool validateOnEnter = true,
    final void Function(String)? onNameChanged,
    final void Function(String)? onSubmitted,
    final int? maxLines = 1,
    final String submitButtonValue = "",
    final String? label,
    String? hintText,
    final TextEditingController? nameController,
    final TextInputAction? textInputAction,
  }) {
    if (hintText == null &&
        nameController != null &&
        nameController.text.isNotEmpty) {
      hintText = nameController.text;
    }

    if (hintText == null) {
      final String generatedHintText =
          "book_create_hint_texts.${Random().nextInt(9)}".tr();
      hintText = generatedHintText;
    }

    final String buttonTextValue =
        submitButtonValue.isNotEmpty ? submitButtonValue : "create".tr();

    String textfieldValue = "";

    return SimpleDialog(
      key: key,
      backgroundColor: Constants.colors.clairPink,
      title: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400.0),
        child: TitleDialog(
          titleValue: titleValue,
          subtitleValue: subtitleValue,
          onCancel: onCancel,
        ),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16.0),
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400.0),
          child: Padding(
            padding: EdgeInsets.all(26.0),
            child: OutlinedTextField(
              label: label,
              controller: nameController,
              hintText: hintText,
              onChanged: (String value) {
                textfieldValue = value;
                onNameChanged?.call(value);
              },
              maxLines: maxLines,
              textInputAction: textInputAction,
              onSubmitted: validateOnEnter ? onSubmitted : null,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(24.0),
          child: DarkElevatedButton.large(
            onPressed: () {
              onSubmitted?.call(textfieldValue);
            },
            child: Text(buttonTextValue),
          ),
        ),
      ],
    );
  }
}
