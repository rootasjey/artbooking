import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/illustration/license.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class EditLicensePageTextInputs extends StatefulWidget {
  const EditLicensePageTextInputs({
    Key? key,
    required this.license,
    this.onValueChange,
  }) : super(key: key);

  final IllustrationLicense license;
  final Function()? onValueChange;

  @override
  State<EditLicensePageTextInputs> createState() =>
      _EditLicensePageTextInputsState();
}

class _EditLicensePageTextInputsState extends State<EditLicensePageTextInputs> {
  final _clairPink = Constants.colors.clairPink;

  var _nameTextController = TextEditingController();
  var _descriptionTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleInput(),
        descriptionInput(),
      ],
    );
  }

  Widget descriptionInput() {
    return Align(
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
                  style: Utilities.fonts.style(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: Utilities.size.isMobileSize(context) ? 300.0 : 600.0,
              child: TextFormField(
                maxLines: null,
                controller: _descriptionTextController,
                onChanged: (newDescription) {
                  widget.license.description = newDescription;
                  // widget.onValueChange?.call();
                },
                decoration: InputDecoration(
                  hintText: "license_description_sample".tr(),
                  filled: true,
                  isDense: true,
                  fillColor: _clairPink,
                  focusColor: _clairPink,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2.0,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget titleInput() {
    return Padding(
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
                style: Utilities.fonts.style(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Container(
            width: Utilities.size.isMobileSize(context) ? 300.0 : 600.0,
            child: TextField(
              autofocus: true,
              controller: _nameTextController,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              style: Utilities.fonts.style(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
              onChanged: (newTitle) {
                widget.license.name = newTitle;
              },
              decoration: InputDecoration(
                hintText: "Attribution 4.0 International",
                filled: true,
                isDense: true,
                fillColor: _clairPink,
                focusColor: _clairPink,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
