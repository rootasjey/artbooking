import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class EditLicensePageTextInputs extends StatelessWidget {
  const EditLicensePageTextInputs({
    Key? key,
    required this.license,
    this.onDescriptionChanged,
    this.onTitleChanged,
  }) : super(key: key);

  final License license;
  final void Function(String)? onDescriptionChanged;
  final void Function(String)? onTitleChanged;

  @override
  Widget build(BuildContext context) {
    final _clairPink = Constants.colors.clairPink;
    var _nameTextController = TextEditingController();
    var _descriptionTextController = TextEditingController();

    _nameTextController.text = license.name;
    _descriptionTextController.text = license.description;

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
                  onChanged: onTitleChanged,
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
                    onChanged: onDescriptionChanged,
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
        ),
      ],
    );
  }
}
