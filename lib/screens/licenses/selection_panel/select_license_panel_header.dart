import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_input.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_tabs.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SelectLicensePanelHeader extends StatelessWidget {
  const SelectLicensePanelHeader({
    Key? key,
    required this.searchInputController,
    this.searching = false,
    this.width = 400.0,
    this.selectedTab = EnumLicenseType.staff,
    this.searchFocusNode,
    this.onChangedTab,
    this.onClearInput,
    this.onClose,
    this.onInputChanged,
    this.trySearchLicense,
  }) : super(key: key);

  /// Searching license matchs according to the search input's value.
  final bool searching;

  /// This widget's width.
  final double width;

  /// Selected tab.
  final EnumLicenseType selectedTab;

  /// Search input focus node to request focus.
  final FocusNode? searchFocusNode;

  /// Callback fired when a tab is selected.
  final void Function(EnumLicenseType enumLicenseType)? onChangedTab;

  /// Callback fired to clear the search input.
  final void Function()? onClearInput;

  /// Callback fired when the close button is tapped.
  final void Function()? onClose;

  /// Callback fired when the search input has changed.
  final void Function(String newValue)? onInputChanged;

  /// Callback fired to search a specific license.
  final void Function()? trySearchLicense;

  /// Search text controller.
  final TextEditingController searchInputController;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0.0,
      child: Container(
        padding: const EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
          color: Constants.colors.clairPink,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: width,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 12.0),
                    child: CircleButton(
                      tooltip: "close".tr(),
                      icon: Icon(
                        UniconsLine.times,
                        color: Colors.black54,
                      ),
                      onTap: onClose,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "licenses_available".tr(),
                            style: Utilities.fonts.body(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Opacity(
                            opacity: 0.5,
                            child: Text(
                              "licenses_panel_subtitle".tr(),
                              style: Utilities.fonts.body(
                                height: 1.0,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SelectLicensePanelTabs(
              selectedTab: selectedTab,
              onChangedTab: onChangedTab,
            ),
            SelectLicensePanelInput(
              onInputChanged: onInputChanged,
              onClearInput: onClearInput,
              searchInputController: searchInputController,
              trySearchLicense: trySearchLicense,
              searchFocusNode: searchFocusNode,
              width: width,
            ),
            SizedBox(
              width: width,
              child: searching
                  ? LinearProgressIndicator()
                  : Divider(
                      thickness: 2.0,
                      color: Theme.of(context).secondaryHeaderColor,
                      height: 0.0,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
