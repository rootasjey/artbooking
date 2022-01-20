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
  }) : super(key: key);

  final Function(String)? onInputChanged;
  final Function()? onSearchLicense;

  @override
  Widget build(BuildContext context) {
    final searchTextController = TextEditingController();

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
                      controller: searchTextController,
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
                        // _searchTimer?.cancel();

                        // _searchTimer = Timer(
                        //   500.milliseconds,
                        //   searchLicense,
                        // );
                        onInputChanged?.call(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Opacity(
                      opacity: 0.6,
                      child: IconButton(
                        tooltip: "styles_search".tr(),
                        icon: Icon(UniconsLine.search),
                        // onPressed: searchLicense,
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
                    searchTextController.clear();
                    // setState(() {
                    //   _searchTextController.clear();
                    // });
                    onInputChanged?.call(searchTextController.text);
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
