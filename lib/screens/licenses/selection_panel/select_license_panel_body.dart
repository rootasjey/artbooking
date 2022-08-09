import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_list.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_more_info.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';

class SelectLicensePanelBody extends StatelessWidget {
  const SelectLicensePanelBody({
    Key? key,
    required this.loading,
    required this.selectedLicense,
    required this.licenses,
    required this.moreInfoLicense,
    required this.panelScrollController,
    this.isMobileSize = false,
    this.searching = false,
    this.showSearchResults = false,
    this.showLicenseInfo = false,
    this.onPageScroll,
    this.onTogglePreview,
    this.toggleLicenseAndUpdate,
  }) : super(key: key);

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  /// Fetching data if true.
  final bool loading;

  /// Searching license matchs according to the search input's value.
  final bool searching;

  /// Show widgets suited for search result if true.
  final bool showSearchResults;

  /// Display more information about a license if true.
  final bool showLicenseInfo;

  /// Callback fired when the page scrolls.
  final void Function(double offset)? onPageScroll;

  /// Callback fired to show or hide the license preview panel.
  final void Function(bool selected, License? license)? onTogglePreview;

  /// Callback fired when a license is un-/selected.
  final void Function(License license, bool selected)? toggleLicenseAndUpdate;

  /// Current selected license.
  final License selectedLicense;

  /// Selected license to show more information
  final License moreInfoLicense;

  /// List of available licenses.
  final List<License> licenses;

  /// Scroll controller.
  final ScrollController panelScrollController;

  @override
  Widget build(BuildContext context) {
    if (showLicenseInfo) {
      return SelectLicensePanelMoreInfo(
        license: moreInfoLicense,
        margin: const EdgeInsets.only(
          top: 260.0,
          bottom: 12.0,
        ),
        onBack: () => onTogglePreview?.call(false, null),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 240.0),
      child: ImprovedScrolling(
        enableKeyboardScrolling: true,
        enableMMBScrolling: true,
        onScroll: onPageScroll,
        scrollController: panelScrollController,
        child: CustomScrollView(
          controller: panelScrollController,
          slivers: [
            SelectLicensePanelList(
              isMobileSize: isMobileSize,
              licenses: licenses,
              loading: loading,
              searching: searching,
              showSearchResults: showSearchResults,
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
