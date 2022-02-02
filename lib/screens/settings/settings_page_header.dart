import 'package:artbooking/components/texts/page_title.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class SettingsPageHeader extends StatelessWidget {
  const SettingsPageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 100.0,
        top: 40.0,
      ),
      sliver: PageTitle(
        crossAxisAlignment: CrossAxisAlignment.start,
        titleValue: "settings".tr(),
        subtitleValue: "settings_description".tr(),
      ),
    );
  }
}
