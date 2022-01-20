import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SelectLicensePanelInput extends StatelessWidget {
  const SelectLicensePanelInput({
    Key? key,
    this.onInputChanged,
    this.onSearchLicense,
    this.searchInputValue = '',
  }) : super(key: key);

  final Function(String)? onInputChanged;
  final Function()? onSearchLicense;
  final String searchInputValue;

  @override
  Widget build(BuildContext context) {
    final searchInput = TextEditingController();
    final searchInputFocus = FocusNode();

    if (searchInputValue.isNotEmpty) {
      searchInput.text = searchInputValue;
      searchInput.selection = TextSelection(
        baseOffset: searchInputValue.length,
        extentOffset: searchInputValue.length,
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(24.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 300.0,
                    child: TextFormField(
                      autofocus: true,
                      controller: searchInput,
                      focusNode: searchInputFocus,
                      decoration: InputDecoration(
                        filled: true,
                        isDense: true,
                        labelText: "license_label_text".tr(),
                        fillColor: Constants.colors.clairPink,
                        focusColor: Constants.colors.clairPink,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 4.0,
                            color: Constants.colors.primary,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        onInputChanged?.call(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Opacity(
                      opacity: 0.6,
                      child: IconButton(
                        tooltip: "license_find".tr(),
                        icon: Icon(UniconsLine.search),
                        onPressed: onSearchLicense,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: TextButton.icon(
                  onPressed: () {
                    searchInput.clear();
                    onInputChanged?.call(searchInput.text);
                    searchInputFocus.requestFocus();
                  },
                  icon: Icon(UniconsLine.times),
                  label: Text("clear".tr()),
                  style: TextButton.styleFrom(
                    primary: Colors.black54,
                    textStyle: Utilities.fonts.style(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
