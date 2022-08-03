import 'package:artbooking/components/texts/page_title.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class SectionsPageHeader extends StatelessWidget {
  const SectionsPageHeader({
    Key? key,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMobileSize ? 12.0 : 54.0,
        bottom: 8.0,
      ),
      child: PageTitle(
        crossAxisAlignment: CrossAxisAlignment.start,
        renderSliver: false,
        subtitleValue: "sections_description".tr(),
        titleValue: "sections".tr(),
      ),
    );
  }
}
