import 'package:artbooking/components/buttons/dark_outlined_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class LicensesPageHeader extends StatelessWidget {
  const LicensesPageHeader({
    Key? key,
    required this.selectedTab,
    this.onChangedTab,
  }) : super(key: key);

  final EnumLicenseType selectedTab;
  final Function(EnumLicenseType)? onChangedTab;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 74.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Opacity(
            opacity: 0.8,
            child: Text(
              "licenses".tr().toUpperCase(),
              style: Utilities.fonts.style(
                fontSize: 30.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Opacity(
            opacity: 0.4,
            child: Text(
              "license_tab_description".tr(),
              style: Utilities.fonts.style(
                fontSize: 16.0,
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
                  onPressed:
                      onChangedTab != null ? onPressedUser : onPressedUser,
                  child: Text("user".tr().toUpperCase()),
                ),
              ],
            ),
          ),
        ]),
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
