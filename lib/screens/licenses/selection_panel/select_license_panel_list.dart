import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SelectLicensePanelList extends StatelessWidget {
  const SelectLicensePanelList({
    Key? key,
    required this.loading,
    required this.licenses,
    required this.selectedLicenseId,
    this.isMobileSize = false,
    this.searching = false,
    this.showSearchResults = false,
    this.onShowLicensePreview,
    this.toggleLicenseAndUpdate,
  }) : super(key: key);

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  /// Fetching data if true.
  final bool loading;

  /// Searching license matchs according to the search input's value.
  final bool searching;

  /// Show specific texts about search results if this field is true.
  final bool showSearchResults;

  /// Callback fired when a license is un-/selected.
  final Function(License license, bool selected)? toggleLicenseAndUpdate;

  /// Callback fired to show more information about a license.
  final Function(License license)? onShowLicensePreview;

  /// List of available licenses.
  final List<License> licenses;

  /// Currently selected license's id.
  final String selectedLicenseId;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SliverList(delegate: SliverChildListDelegate.fixed([]));
    }

    if (licenses.isEmpty && !searching) {
      return SliverPadding(
        padding: const EdgeInsets.only(
          bottom: 24.0,
          left: 24.0,
          right: 24.0,
          top: 60.0,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate.fixed([
            Opacity(
              opacity: 0.6,
              child: Icon(
                UniconsLine.no_entry,
                size: isMobileSize ? 40.0 : 80.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  showSearchResults
                      ? "license_search_result_empty".tr()
                      : "license_personal_empty_create".tr(),
                  textAlign: TextAlign.center,
                  style: Utilities.fonts.body(
                    fontSize: isMobileSize ? 18.0 : 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (!showSearchResults)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: DarkElevatedButton(
                    onPressed: () => Beamer.of(context).beamToNamed(
                      AtelierLocationContent.licensesRoute,
                    ),
                    child: Text("license_personal_create".tr()),
                  ),
                ),
              ),
          ]),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final License currentLicense = licenses.elementAt(index);
            final bool selected = selectedLicenseId == currentLicense.id;

            return ListTile(
              onLongPress: () => onShowLicensePreview?.call(currentLicense),
              onTap: () => toggleLicenseAndUpdate?.call(
                currentLicense,
                selected,
              ),
              title: Opacity(
                opacity: 0.8,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentLicense.name,
                        style: Utilities.fonts.body(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Theme.of(context).secondaryHeaderColor
                              : null,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(
                        UniconsLine.check,
                        color: selected
                            ? Theme.of(context).secondaryHeaderColor
                            : null,
                      ),
                  ],
                ),
              ),
              subtitle: Text(
                currentLicense.description,
                maxLines: isMobileSize ? 3 : null,
                overflow: TextOverflow.ellipsis,
                style: Utilities.fonts.body(
                  fontWeight: FontWeight.w600,
                ),
              ),
              contentPadding: isMobileSize
                  ? const EdgeInsets.all(6.0)
                  : const EdgeInsets.all(16.0),
            );
          },
          childCount: licenses.length,
        ),
      ),
    );
  }
}
