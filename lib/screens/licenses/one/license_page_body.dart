import 'package:artbooking/components/buttons/text_rectangle_button.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/one/license_page_dates.dart';
import 'package:artbooking/screens/licenses/one/license_page_urls.dart';
import 'package:artbooking/screens/licenses/one/license_page_usage.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class LicensePageBody extends StatelessWidget {
  const LicensePageBody({
    Key? key,
    required this.license,
    required this.isLoading,
    this.isDeleting = false,
    this.onEditLicense,
    this.onDeleteLicense,
    required this.canManageLicense,
  }) : super(key: key);

  final License license;
  final bool isLoading;
  final bool isDeleting;
  final bool canManageLicense;
  final Function()? onEditLicense;
  final Function()? onDeleteLicense;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(60.0),
      sliver: isLoading || isDeleting ? loadingView() : idleView(),
    );
  }

  Widget idleView() {
    final bool isPending = isLoading || isDeleting;

    return SliverList(
      delegate: SliverChildListDelegate.fixed(
        [
          Opacity(
            opacity: 0.4,
            child: Text(
              "version: ${license.version}".toUpperCase(),
              style: Utilities.fonts.style(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            license.name,
            style: Utilities.fonts.style(
              fontSize: 32.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          Opacity(
            opacity: 0.6,
            child: Text(
              license.description,
              style: Utilities.fonts.style(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          LicensePageDates(
            createdAt: license.createdAt,
            updatedAt: license.updatedAt,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 42.0),
            child: LicensePageUsage(
              usage: license.usage,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 42.0),
            child: LicensePageUrls(
              urls: license.urls,
            ),
          ),
          if (canManageLicense)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Wrap(
                spacing: 20.0,
                children: [
                  TextRectangleButton(
                    onPressed: isPending ? null : onEditLicense,
                    icon: Icon(UniconsLine.edit),
                    label: Text('edit'.tr()),
                    primary: Colors.black38,
                  ),
                  TextRectangleButton(
                    onPressed: isPending ? null : onDeleteLicense,
                    icon: Icon(UniconsLine.trash),
                    label: Text('delete'.tr()),
                    primary: Colors.black38,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget loadingView() {
    final String pendingAction =
        isDeleting ? "license_deleting".tr() : "license_loading".tr();

    return LoadingView(
      sliver: true,
      title: Text(pendingAction + "..."),
    );
  }
}
