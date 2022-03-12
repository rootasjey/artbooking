import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/one/license_page_dates.dart';
import 'package:artbooking/screens/sections/one/section_page_actions.dart';
import 'package:artbooking/screens/sections/one/section_page_background.dart';
import 'package:artbooking/screens/sections/one/section_page_data_modes.dart';
import 'package:artbooking/screens/sections/one/section_page_data_types.dart';
import 'package:artbooking/screens/sections/one/section_page_header_separtor.dart';
import 'package:artbooking/screens/sections/one/section_page_title.dart';
import 'package:artbooking/types/section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SectionPageBody extends StatelessWidget {
  const SectionPageBody({
    Key? key,
    required this.loading,
    required this.deleting,
    required this.section,
    this.onDeleteSection,
    this.onEditSection,
  }) : super(key: key);

  final bool loading;
  final bool deleting;
  final Section section;

  /// onDelete callback function (after selecting 'delete' item menu)
  final Function()? onDeleteSection;

  /// onEdit callback function (after selecting 'edit' item menu)
  final Function()? onEditSection;

  @override
  Widget build(BuildContext context) {
    final String pendingAction =
        deleting ? "license_deleting".tr() : "license_loading".tr();

    if (loading || deleting) {
      return SliverPadding(
        padding: const EdgeInsets.only(
          top: 60.0,
          left: 60.0,
          right: 60.0,
          bottom: 260.0,
        ),
        sliver: LoadingView(
          sliver: true,
          title: Text(pendingAction + "..."),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 60.0,
        right: 60.0,
        bottom: 260.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed(
          [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                tooltip: "back".tr(),
                onPressed: () => Utilities.navigation.back(context),
                icon: Icon(UniconsLine.arrow_left),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 42),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionPageTitle(
                    sectionId: section.id,
                  ),
                  SectionPageActions(
                    onDeleteSection: onDeleteSection,
                    onEditSection: onEditSection,
                  ),
                  LicensePageDates(
                    createdAt: section.createdAt,
                    updatedAt: section.updatedAt,
                    padding: const EdgeInsets.only(bottom: 24.0),
                  ),
                  SectionPageBackground(
                    backgroundColor: section.backgroundColor,
                  ),
                  SectionPageDataModes(
                    dataModes: section.dataFetchModes,
                    padding: const EdgeInsets.only(top: 24.0),
                  ),
                  SectionPageDataTypes(
                    dataTypes: section.dataTypes,
                    padding: const EdgeInsets.only(top: 24.0),
                  ),
                  SectionPageHeaderSeparator(
                    headerSeparator: section.headerSeparator,
                    padding: const EdgeInsets.only(top: 24.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
