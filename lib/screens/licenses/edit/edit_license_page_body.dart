import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/screens/licenses/edit/edit_license_page_links.dart';
import 'package:artbooking/screens/licenses/edit/edit_license_page_usage.dart';
import 'package:artbooking/components/edit_title_description.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:artbooking/types/license/license_links.dart';
import 'package:artbooking/types/license/license_usage.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class EditLicensePageBody extends StatelessWidget {
  const EditLicensePageBody({
    Key? key,
    required this.isLoading,
    required this.isSaving,
    required this.isNewLicense,
    required this.license,
    this.onUsageValueChange,
    this.onValidate,
    this.onTitleChanged,
    this.onDescriptionChanged,
    this.onLinkValueChange,
  }) : super(key: key);

  final bool isLoading;
  final bool isSaving;

  /// True if we create a new license. It's an update therwise.
  final bool isNewLicense;
  final License license;

  final void Function(LicenseUsage)? onUsageValueChange;
  final void Function(LicenseLinks)? onLinkValueChange;
  final void Function()? onValidate;
  final void Function(String)? onTitleChanged;
  final void Function(String)? onDescriptionChanged;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingView(
        sliver: false,
        title: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Opacity(
            opacity: 0.6,
            child: Text("loading".tr()),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 90.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditTitleDescription(
            descriptionHintText: "license_description_sample".tr(),
            initialDescription: license.description,
            initialName: license.name,
            onTitleChanged: onTitleChanged,
            onDescriptionChanged: onDescriptionChanged,
          ),
          EditLicensePageUsage(
            usage: license.usage,
            onValueChange: onUsageValueChange,
          ),
          EditLicensePageLinks(
            links: license.links,
            onValueChange: onLinkValueChange,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 80.0),
            child: DarkElevatedButton.large(
              onPressed: isSaving ? null : onValidate,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64.0),
                child: Text(
                  isNewLicense ? "create".tr() : "update".tr(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
