import 'package:artbooking/components/texts/page_title.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class ActivityPageHeader extends StatelessWidget {
  const ActivityPageHeader({
    Key? key,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, will adapt this widget for small screen (responsive).
  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 60.0,
        left: isMobileSize ? 12.0 : 54.0,
        bottom: 24.0,
      ),
      child: PageTitle(
        crossAxisAlignment: CrossAxisAlignment.start,
        isMobileSize: isMobileSize,
        subtitleValue: "activity_subtitle".tr(),
        titleValue: "activity".tr(),
        renderSliver: false,
      ),
    );
  }
}
