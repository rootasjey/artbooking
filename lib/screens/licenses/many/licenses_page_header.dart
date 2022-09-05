import 'package:artbooking/components/buttons/dark_outlined_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class LicensesPageHeader extends StatelessWidget {
  const LicensesPageHeader({
    Key? key,
    required this.selectedTab,
    this.isMobileSize = false,
    this.onChangedTab,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// Currently selected tab (staff or user).
  final EnumLicenseType selectedTab;

  /// Callback fired when changing tab.
  final Function(EnumLicenseType licenseType)? onChangedTab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMobileSize ? 12.0 : 54.0,
        bottom: 8.0,
      ),
      child: Column(
        children: [
          Opacity(
            opacity: 0.8,
            child: Text(
              "licenses".tr(),
              style: Utilities.fonts.body(
                fontSize: isMobileSize ? 24.0 : 30.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Opacity(
            opacity: 0.4,
            child: Text(
              "license_tab_description".tr(),
              style: Utilities.fonts.body(
                fontSize: isMobileSize ? 14.0 : 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                DarkOutlinedButton(
                  selected: EnumLicenseType.staff == selectedTab,
                  onPressed: onChangedTab != null ? onPressedStaff : null,
                  child: Text("staff".tr().toUpperCase()),
                ),
                DarkOutlinedButton(
                  selected: EnumLicenseType.user == selectedTab,
                  onPressed: onChangedTab != null ? onPressedUser : null,
                  child: Text("user".tr().toUpperCase()),
                ),
              ],
            ),
          ),
        ],
        crossAxisAlignment: isMobileSize
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.stretch,
      ),
    );
  }

  void onPressedStaff() {
    onChangedTab?.call(EnumLicenseType.staff);
  }

  void onPressedUser() {
    onChangedTab?.call(EnumLicenseType.user);
  }
}
