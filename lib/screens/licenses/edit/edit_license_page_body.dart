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
    required this.loading,
    required this.saving,
    required this.isNewLicense,
    required this.license,
    this.onUsageValueChange,
    this.onTitleChanged,
    this.onDescriptionChanged,
    this.onLinkValueChange,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// Currently loading license data if true.
  final bool loading;

  /// Currently saving license data if true.
  final bool saving;

  /// True if we create a new license. It's an update therwise.
  final bool isNewLicense;

  /// Main page data.
  final License license;

  /// Callback fired when selected usage is updated.
  final void Function(LicenseUsage)? onUsageValueChange;

  /// Callback fired when license's link is updated.
  final void Function(LicenseLinks)? onLinkValueChange;

  /// Callback fired when title is updated.
  final void Function(String)? onTitleChanged;

  /// Callback fired when descriptionis updated.
  final void Function(String)? onDescriptionChanged;

  @override
  Widget build(BuildContext context) {
    if (loading) {
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
      padding: EdgeInsets.only(
        top: isMobileSize ? 24.0 : 90.0,
        bottom: 200.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditTitleDescription(
            descriptionHintText: "license_description_sample".tr(),
            initialDescription: license.description,
            initialName: license.name,
            isMobileSize: isMobileSize,
            titleHintText: "Attribution 4.0 International",
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
        ],
      ),
    );
  }
}
