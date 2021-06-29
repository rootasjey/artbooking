import 'dart:math';

import 'package:artbooking/components/dark_elevated_button.dart';
import 'package:artbooking/components/dot_close_button.dart';
import 'package:artbooking/components/outlined_text_field.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A dialog to create/edit a new book.
class CreateOrEditBookDialog extends StatelessWidget {
  const CreateOrEditBookDialog({
    Key? key,
    required this.textTitle,
    required this.textSubtitle,
    this.nameController,
    this.onNameChanged,
    this.onDescriptionChanged,
    required this.onSubmitted,
    required this.onCancel,
    this.descriptionController,
  }) : super(key: key);

  final String textTitle;
  final String textSubtitle;
  final TextEditingController? nameController;
  final TextEditingController? descriptionController;
  final void Function(String)? onNameChanged;
  final void Function(String)? onDescriptionChanged;
  final void Function(String) onSubmitted;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: stateColors.clairPink,
      title: title(),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16.0),
      children: [
        nameInput(),
        descriptionInput(),
        footerButtons(),
      ],
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
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: DarkElevatedButton(
        onPressed: () {
          final String value = nameController?.text ?? '';
          onSubmitted.call(value);
        },
        child: Text("create".tr()),
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
      ),
    );
  }

  Widget title() {
    return Stack(
      children: [
        closeButton(),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 24.0,
                right: 24.0,
              ),
              child: Column(
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      textTitle,
                      style: FontsUtils.mainStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.4,
                    child: Text(
                      textSubtitle,
                      style: FontsUtils.mainStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Divider(
                thickness: 1.5,
                color: stateColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
