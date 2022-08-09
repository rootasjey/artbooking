import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/components/inputs/search_text_input.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SelectLicensePanelInput extends StatelessWidget {
  const SelectLicensePanelInput({
    Key? key,
    required this.searchInputController,
    this.onInputChanged,
    this.trySearchLicense,
    this.width = 300.0,
    this.isMobileSize = false,
    this.onClearInput,
    this.searchFocusNode,
  }) : super(key: key);

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  /// This widget's width.
  final double width;

  /// Search focus node to request focus.
  final FocusNode? searchFocusNode;

  /// Callback fired when the search input value has changed.
  final void Function(String newValue)? onInputChanged;

  /// Callback fired to search a specific license..
  final void Function()? trySearchLicense;

  /// Callback fired to clear the search input.
  final void Function()? onClearInput;

  /// Search text controller.
  final TextEditingController searchInputController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isMobileSize
          ? EdgeInsets.only(left: 8.0, right: 6.0, top: 24.0)
          : const EdgeInsets.all(24.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchTextInput(
            autofocus: true,
            controller: searchInputController,
            focusNode: searchFocusNode,
            label: "search".tr(),
            hintText: "license_label_text".tr(),
            constraints: BoxConstraints(
              maxWidth: width - 90.0,
              maxHeight: 140.0,
            ),
            onChanged: onInputChanged,
            onClearInput: onClearInput,
          ),
          CircleButton(
            icon: Icon(UniconsLine.search, color: Colors.black87),
            margin: const EdgeInsets.only(left: 4.0, top: 18.0),
            onTap: trySearchLicense,
          ),
        ],
      ),
    );
  }
}
