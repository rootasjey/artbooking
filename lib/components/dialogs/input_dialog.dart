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
    required this.titleValue,
    required this.subtitleValue,
    this.nameController,
    this.onNameChanged,
    this.onDescriptionChanged,
    required this.onSubmitted,
    required this.onCancel,
    this.descriptionController,
    this.submitButtonValue = '',
  }) : super(key: key);

  final String submitButtonValue;
  final String titleValue;
  final String subtitleValue;
  final TextEditingController? nameController;
  final TextEditingController? descriptionController;
  final void Function(String)? onNameChanged;
  final void Function(String)? onDescriptionChanged;
  final void Function(String) onSubmitted;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: Constants.colors.clairPink,
      title: TitleDialog(
        titleValue: titleValue,
        subtitleValue: subtitleValue,
        onCancel: onCancel,
      ),
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
    final TextEditingController? nameController,
    final void Function(String)? onNameChanged,
    final void Function(String)? onSubmitted,
    required final void Function() onCancel,
    final int? maxLines = 1,
    final String submitButtonValue = '',
    final String? label,
    String? hintText,
    final TextInputAction? textInputAction,
    final void Function(String)? onSubmitInput,
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
              onChanged: onNameChanged,
              maxLines: maxLines,
              textInputAction: textInputAction,
              onSubmitted: onSubmitInput,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(24.0),
          child: DarkElevatedButton.large(
            onPressed: () {
              final String value = nameController?.text ?? '';
              onSubmitted?.call(value);
            },
            child: Text(buttonTextValue),
          ),
        ),
      ],
    );
  }
}
