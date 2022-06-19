import 'package:artbooking/components/texts/outlined_text_field.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

/// A component which contains 2 text inputs,
/// first for the title, second for the description.
class EditTitleDescription extends StatefulWidget {
  const EditTitleDescription({
    Key? key,
    this.onDescriptionChanged,
    this.onTitleChanged,
    this.initialName = "",
    this.initialDescription = "",
    this.descriptionHintText = "",
    this.titleHintText = "",
  }) : super(key: key);

  /// Initial section's name.
  final String initialName;

  /// Initial section's description.
  final String initialDescription;

  /// Will be shown as a default value inside the title input.
  final String titleHintText;

  /// Will be shown as a default value inside the description input.
  final String descriptionHintText;

  /// Callback event fired when this section's description is udpated.
  final void Function(String)? onDescriptionChanged;

  /// Callback event fired when this section's title is udpated.
  final void Function(String)? onTitleChanged;

  @override
  State<EditTitleDescription> createState() => _EditTitleDescriptionState();
}

class _EditTitleDescriptionState extends State<EditTitleDescription> {
  final _nameTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _nameTextController.text = widget.initialName;
    _descriptionTextController.text = widget.initialDescription;
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _descriptionTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(
                opacity: 0.6,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "title".tr(),
                    style: Utilities.fonts.body(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 300.0,
                child: OutlinedTextField(
                  controller: _nameTextController,
                  onChanged: widget.onTitleChanged,
                  hintText: widget.titleHintText,
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0.6,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "description".tr(),
                      style: Utilities.fonts.body(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 300.0,
                  child: OutlinedTextField(
                    hintText: widget.descriptionHintText,
                    controller: _descriptionTextController,
                    onChanged: widget.onDescriptionChanged,
                    maxLines: null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
