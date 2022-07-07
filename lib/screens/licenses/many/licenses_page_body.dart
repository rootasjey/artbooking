import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/license_card_item.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class LicensesPageBody extends StatelessWidget {
  const LicensesPageBody({
    Key? key,
    required this.licenses,
    required this.loading,
    this.onDeleteLicense,
    this.onEditLicense,
    this.onTap,
    this.onCreateLicense,
    required this.selectedTab,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// List of licenses (main data).
  final List<License> licenses;

  /// True if data is currently loading.
  final bool loading;

  /// Callback to confirm license deletion.
  final Function(License, int)? onDeleteLicense;

  /// Callback to navigate to license edit page.
  final Function(License, int)? onEditLicense;

  /// Callback to go to the license create page.
  final Function()? onCreateLicense;

  /// Callback fired after license tap.
  final Function(License)? onTap;

  /// Currently selected tab (staff or user).
  final EnumLicenseType selectedTab;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LoadingView(
        sliver: true,
        title: Text(
          "licenses_loading".tr() + "...",
          style: Utilities.fonts.body(
            fontSize: 32.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (licenses.isEmpty) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobileSize ? 12.0 : 80.0,
          vertical: 69.0,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate.fixed([
            Align(
              alignment: Alignment.topLeft,
              child: Opacity(
                opacity: 0.6,
                child: Icon(
                  UniconsLine.no_entry,
                  size: 80.0,
                ),
              ),
            ),
            Opacity(
              opacity: 0.6,
              child: Text(
                selectedTab == EnumLicenseType.staff
                    ? "license_staff_empty_create".tr()
                    : "license_personal_empty_create".tr(),
                style: Utilities.fonts.body(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: DarkElevatedButton(
                  onPressed: onCreateLicense,
                  child: Text(
                    selectedTab == EnumLicenseType.staff
                        ? "license_staff_create".tr()
                        : "license_personal_create".tr(),
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        left: isMobileSize ? 0.0 : 34.0,
        right: isMobileSize ? 0.0 : 30.0,
        bottom: 300.0,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final License license = licenses.elementAt(index);

            return LicenseCardItem(
              key: ValueKey(license.id),
              index: index,
              license: license,
              onTap: onTap,
              onDelete: onDeleteLicense,
              onEdit: onEditLicense,
            );
          },
          childCount: licenses.length,
        ),
      ),
    );
  }
}
