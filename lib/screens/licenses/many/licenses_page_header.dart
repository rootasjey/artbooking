import 'package:artbooking/components/buttons/dark_outlined_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/license_from.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class LicensesPageHeader extends StatelessWidget {
  const LicensesPageHeader({
    Key? key,
    required this.selectedTab,
    this.onChangedTab,
  }) : super(key: key);

  final EnumLicenseCreatedBy selectedTab;
  final Function(EnumLicenseCreatedBy)? onChangedTab;

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
                  selected: EnumLicenseCreatedBy.staff == selectedTab,
                  onPressed: onChangedTab != null ? onPressedStaff : null,
                  child: Text("staff".tr().toUpperCase()),
                ),
                DarkOutlinedButton(
                  selected: EnumLicenseCreatedBy.user == selectedTab,
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
    onChangedTab?.call(EnumLicenseCreatedBy.staff);
  }

  void onPressedUser() {
    onChangedTab?.call(EnumLicenseCreatedBy.user);
  }
}
