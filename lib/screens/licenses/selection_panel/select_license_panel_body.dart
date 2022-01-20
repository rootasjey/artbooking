import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_input.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_list.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_more_info.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_tabs.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:flutter/material.dart';

class SelectLicensePanelBody extends StatelessWidget {
  const SelectLicensePanelBody({
    Key? key,
    this.showLicenseInfo = false,
    this.onScrollNotification,
    this.panelScrollController,
    this.onInputChanged,
    this.onSearchLicense,
    required this.selectedLicense,
    this.onTogglePreview,
    this.searchInputValue = '',
    required this.licenses,
    this.toggleLicenseAndUpdate,
    required this.moreInfoLicense,
    required this.selectedTab,
    this.onChangedTab,
    required this.isLoading,
  }) : super(key: key);

  final bool isLoading;
  final bool showLicenseInfo;
  final bool Function(ScrollNotification)? onScrollNotification;

  final Function(String)? onInputChanged;
  final Function()? onSearchLicense;
  final Function(bool, License?)? onTogglePreview;
  final Function(License, bool)? toggleLicenseAndUpdate;

  final License selectedLicense;
  final License moreInfoLicense;
  final List<License> licenses;

  final ScrollController? panelScrollController;
  final String searchInputValue;

  final EnumLicenseType selectedTab;
  final Function(EnumLicenseType)? onChangedTab;

  @override
  Widget build(BuildContext context) {
    if (showLicenseInfo) {
      return SelectLicensePanelMoreInfo(
        license: moreInfoLicense,
        onBack: () => onTogglePreview?.call(false, null),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 120.0),
      child: NotificationListener<ScrollNotification>(
        onNotification: onScrollNotification,
        child: CustomScrollView(
          controller: panelScrollController,
          slivers: [
            SelectLicensePanelTabs(
              selectedTab: selectedTab,
              onChangedTab: onChangedTab,
            ),
            SelectLicensePanelInput(
              onInputChanged: onInputChanged,
              onSearchLicense: onSearchLicense,
              searchInputValue: searchInputValue,
            ),
            SelectLicensePanelList(
              licenses: licenses,
              isLoading: isLoading,
              searchON: searchInputValue.isNotEmpty,
              selectedLicenseId: selectedLicense.id,
              toggleLicenseAndUpdate: toggleLicenseAndUpdate,
              onShowLicensePreview: (license) => onTogglePreview?.call(
                !showLicenseInfo,
                license,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
