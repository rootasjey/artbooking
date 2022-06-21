import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/dates_wrap.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/one/license_page_links.dart';
import 'package:artbooking/screens/licenses/one/license_page_usage.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class LicensePageBody extends StatelessWidget {
  const LicensePageBody({
    Key? key,
    required this.license,
    required this.loading,
    this.deleting = false,
    this.onEditLicense,
    this.onDeleteLicense,
    required this.canManageLicense,
  }) : super(key: key);

  /// Fetching data on the license.
  final bool loading;

  /// Currently deleting the displayed license if true.
  final bool deleting;

  /// If true, the current authenticated user has the right to
  /// create/update/delete staff licenses.
  final bool canManageLicense;

  /// Actual license.
  final License license;

  /// Callback fired when we want to edit a license.
  final Function()? onEditLicense;

  /// Callback fired when we want to delete a license.
  final Function()? onDeleteLicense;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 12.0,
        left: 60.0,
        right: 60.0,
        bottom: 260.0,
      ),
      sliver: loading || deleting ? loadingView() : idleView(),
    );
  }

  Widget idleView() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Hero(
          tag: license.name,
          child: Text(
            license.name,
            style: Utilities.fonts.body3(
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FadeInY(
          beginY: 12.0,
          delay: Duration(milliseconds: 4),
          child: Opacity(
            opacity: 0.4,
            child: Text(
              "version_number".tr(args: [license.version]),
              style: Utilities.fonts.body(
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        FadeInY(
          beginY: 12.0,
          delay: Duration(milliseconds: 25),
          child: Opacity(
            opacity: 0.6,
            child: Text(
              license.description,
              style: Utilities.fonts.body(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        DatesWrap(
          createdAt: license.createdAt,
          updatedAt: license.updatedAt,
          margin: const EdgeInsets.only(top: 12.0),
        ),
        LicensePageUsage(
          usage: license.usage,
          margin: const EdgeInsets.only(top: 42.0),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 42.0),
          child: LicensePageLinks(
            links: license.links,
          ),
        ),
      ]),
    );
  }

  Widget loadingView() {
    final String pendingAction =
        deleting ? "license_deleting".tr() : "license_loading".tr();

    return LoadingView(
      sliver: true,
      title: Text(pendingAction + "..."),
    );
  }
}
