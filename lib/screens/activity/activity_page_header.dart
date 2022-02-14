import 'package:artbooking/components/texts/page_title.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class ActivityPageHeader extends StatelessWidget {
  const ActivityPageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 54.0,
        bottom: 24.0,
      ),
      sliver: PageTitle(
        titleValue: "activity".tr(),
        subtitleValue: "activity_subtitle".tr(),
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
