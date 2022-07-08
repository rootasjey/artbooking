import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/dates_wrap.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/sections/edit/edit_section_colors.dart';
import 'package:artbooking/screens/sections/edit/edit_section_data_fetch_modes.dart';
import 'package:artbooking/screens/sections/edit/edit_section_data_types.dart';
import 'package:artbooking/screens/sections/edit/edit_section_header_separator.dart';
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
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// Fetching section's data if true.
  final bool loading;

  /// Deleting section is true.
  final bool deleting;

  /// Main page data.
  final Section section;

  @override
  Widget build(BuildContext context) {
    final String pendingAction =
        deleting ? "license_deleting".tr() : "license_loading".tr();

    if (loading || deleting) {
      return SliverPadding(
        padding: EdgeInsets.only(
          top: isMobileSize ? 24.0 : 60.0,
          left: isMobileSize ? 12.0 : 60.0,
          right: isMobileSize ? 12.0 : 60.0,
          bottom: 260.0,
        ),
        sliver: LoadingView(
          sliver: true,
          title: Text(pendingAction + "..."),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        top: isMobileSize ? 24.0 : 60.0,
        left: isMobileSize ? 12.0 : 60.0,
        right: isMobileSize ? 12.0 : 60.0,
        bottom: 200.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          if (!isMobileSize)
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                tooltip: "back".tr(),
                onPressed: () => Utilities.navigation.back(context),
                icon: Icon(UniconsLine.arrow_left),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              children: [
                SizedBox(
                  width: 500.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionPageTitle(
                        sectionId: section.id,
                      ),
                      DatesWrap(
                        createdAt: section.createdAt,
                        updatedAt: section.updatedAt,
                        margin: const EdgeInsets.only(bottom: 24.0),
                      ),
                      FadeInY(
                        beginY: 12.0,
                        delay: Duration(milliseconds: 75),
                        child: Divider(height: 54.0),
                      ),
                      EditSectionColors(
                        section: section,
                        margin: const EdgeInsets.only(top: 24.0),
                      ),
                      EditSectionDataFetchModes(
                        editMode: false,
                        dataModes: section.dataFetchModes,
                        margin: const EdgeInsets.only(top: 12.0),
                      ),
                      EditSectionDataTypes(
                        editMode: false,
                        dataTypes: section.dataTypes,
                        margin: const EdgeInsets.only(top: 24.0),
                      ),
                      EditSectionHeaderSeparator(
                        editMode: false,
                        headerSeparator: section.headerSeparator,
                        margin: const EdgeInsets.only(top: 24.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
