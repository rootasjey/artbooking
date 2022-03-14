import 'package:artbooking/globals/constants.dart';
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

  final String initialName;
  final String initialDescription;
  final String titleHintText;
  final String descriptionHintText;
  final void Function(String)? onDescriptionChanged;
  final void Function(String)? onTitleChanged;

  @override
  State<EditTitleDescription> createState() => _EditTitleDescriptionState();
}

class _EditTitleDescriptionState extends State<EditTitleDescription> {
  final _clairPink = Constants.colors.clairPink;
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
                  onChanged: widget.onTitleChanged,
                  decoration: InputDecoration(
                    hintText: widget.titleHintText,
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
                  child: TextField(
                    maxLines: null,
                    controller: _descriptionTextController,
                    onChanged: widget.onDescriptionChanged,
                    decoration: InputDecoration(
                      hintText: widget.descriptionHintText,
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
