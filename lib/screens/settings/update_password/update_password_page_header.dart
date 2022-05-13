import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class UpdatePasswordPageHeader extends StatelessWidget {
  const UpdatePasswordPageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 80.0, top: 80.0),
      sliver: PageTitle(
        showBackButton: true,
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
                "password_update".tr(),
                style: Utilities.fonts.body(
                  color: Theme.of(context).primaryColor,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        subtitleValue: "password_update_description".tr(),
      ),
    );
  }
}
