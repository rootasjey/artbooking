import 'package:artbooking/components/buttons/dark_outlined_button.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class SelectLicensePanelTabs extends StatelessWidget {
  const SelectLicensePanelTabs({
    Key? key,
    required this.selectedTab,
    this.onChangedTab,
  }) : super(key: key);

  final EnumLicenseType selectedTab;
  final Function(EnumLicenseType)? onChangedTab;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 24.0),
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
                onPressed: onChangedTab != null ? onPressedUser : onPressedUser,
                child: Text("user".tr().toUpperCase()),
              ),
            ],
          ),
        )
      ]),
    );
  }

  void onPressedStaff() {
    onChangedTab?.call(EnumLicenseType.staff);
  }

  void onPressedUser() {
    onChangedTab?.call(EnumLicenseType.user);
  }
}
