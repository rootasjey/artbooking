import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_input.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_list.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_preview.dart';
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
  }) : super(key: key);

  final bool showLicenseInfo;
  final bool Function(ScrollNotification)? onScrollNotification;
  final ScrollController? panelScrollController;

  final Function(String)? onInputChanged;
  final Function()? onSearchLicense;
  final Function(bool)? onTogglePreview;
  final Function(License, bool)? toggleLicenseAndUpdate;

  final License selectedLicense;
  final String searchInputValue;

  final List<License> licenses;

  @override
  Widget build(BuildContext context) {
    if (showLicenseInfo) {
      return SelectLicensePanelPreview(
        selectedLicensePreview: selectedLicense,
        onBack: () => onTogglePreview?.call(false),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 120.0),
      child: NotificationListener<ScrollNotification>(
        onNotification: onScrollNotification,
        child: CustomScrollView(
          controller: panelScrollController,
          slivers: [
            SelectLicensePanelInput(
              onInputChanged: onInputChanged,
              onSearchLicense: onSearchLicense,
            ),
            SelectLicensePanelList(
              licenses: licenses,
              selectedLicenseId: selectedLicense.id,
              toggleLicenseAndUpdate: toggleLicenseAndUpdate,
              onShowLicensePreview: () => onTogglePreview?.call(
                !showLicenseInfo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
