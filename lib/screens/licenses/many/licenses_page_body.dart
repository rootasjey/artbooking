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
    required this.isLoading,
    this.onDeleteLicense,
    this.onEditLicense,
    this.onTap,
    this.onCreateLicense,
    required this.selectedTab,
  }) : super(key: key);

  final List<License> licenses;
  final bool isLoading;
  final Function(License, int)? onDeleteLicense;
  final Function(License, int)? onEditLicense;
  final Function()? onCreateLicense;
  final Function(License)? onTap;
  final EnumLicenseType selectedTab;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
        padding: const EdgeInsets.symmetric(
          horizontal: 80.0,
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
      padding: const EdgeInsets.only(
        left: 34.0,
        right: 30.0,
        bottom: 300.0,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final license = licenses.elementAt(index);

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
