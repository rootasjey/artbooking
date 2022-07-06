import 'package:artbooking/components/texts/page_title.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class SettingsPageHeader extends StatelessWidget {
  const SettingsPageHeader({
    Key? key,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        left: isMobileSize ? 12.0 : 54.0,
        top: isMobileSize ? 24.0 : 60.0,
      ),
      sliver: PageTitle(
        crossAxisAlignment: CrossAxisAlignment.start,
        titleValue: "settings".tr(),
        subtitleValue: "settings_description".tr(),
      ),
    );
  }
}
