import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class UpdateUsernamePageHeader extends StatelessWidget {
  const UpdateUsernamePageHeader({
    Key? key,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        left: isMobileSize ? 12.0 : 80.0,
        top: isMobileSize ? 24.0 : 80.0,
        bottom: isMobileSize ? 24.0 : 0.0,
      ),
      sliver: PageTitle(
        showBackButton: !isMobileSize,
        title: Wrap(
          children: [
            Opacity(
              opacity: 0.8,
              child: Text(
                "settings".tr() + ": ",
                style: Utilities.fonts.body(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Opacity(
              opacity: 0.8,
              child: Text(
                "username_update".tr(),
                style: Utilities.fonts.body(
                  color: Theme.of(context).primaryColor,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        subtitleValue: "username_update_description".tr(),
      ),
    );
  }
}
