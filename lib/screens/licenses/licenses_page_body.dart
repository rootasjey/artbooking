import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/screens/licenses/license_card_item.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class LicensesPageBody extends StatelessWidget {
  const LicensesPageBody({
    Key? key,
    required this.licenses,
    required this.isLoading,
    this.onDeleteLicense,
    this.onEditLicense,
  }) : super(key: key);

  final List<License> licenses;
  final bool isLoading;
  final Function(License, int)? onDeleteLicense;
  final Function(License, int)? onEditLicense;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingView(
        sliver: true,
        title: Text(
          "licenses_loading".tr() + "...",
          style: Utilities.fonts.style(
            fontSize: 32.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 54.0,
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
              onTap: (tappedLicense) {
                final route = DashboardLocationContent.licenseRoute
                    .replaceFirst(':licenseId', license.id);

                Beamer.of(context).beamToNamed(route, data: {
                  'licenseId': license.id,
                });
              },
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
