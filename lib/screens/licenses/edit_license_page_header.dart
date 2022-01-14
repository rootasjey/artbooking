import 'package:artbooking/components/sheet_header.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class EditLicensePageHeader extends StatelessWidget {
  const EditLicensePageHeader({
    Key? key,
    required this.licenseId,
    required this.licenseName,
  }) : super(key: key);

  final String licenseId;
  final String licenseName;

  @override
  Widget build(BuildContext context) {
    final String headerTitleValue =
        licenseName.isEmpty ? "new".tr() : "edit".tr() + " $licenseName";

    final String headerSubtitle = licenseId.isEmpty
        ? "license_create".tr()
        : "license_edit_existing".tr();

    return SheetHeader(
      title: headerTitleValue,
      tooltip: "close".tr(),
      subtitle: headerSubtitle,
    );
  }
}
