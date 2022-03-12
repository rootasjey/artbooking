import 'package:artbooking/components/texts/page_title.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class SectionsPageHeader extends StatelessWidget {
  const SectionsPageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 54.0,
        top: 60.0,
      ),
      sliver: PageTitle(
        crossAxisAlignment: CrossAxisAlignment.start,
        titleValue: "sections".tr(),
        subtitleValue: "sections_description".tr(),
      ),
    );
  }
}
