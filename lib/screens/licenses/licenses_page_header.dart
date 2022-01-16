import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class LicensesPageHeader extends StatelessWidget {
  const LicensesPageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 74.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Opacity(
            opacity: 0.8,
            child: Text(
              "licenses".tr().toUpperCase(),
              style: Utilities.fonts.style(
                fontSize: 30.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Opacity(
            opacity: 0.4,
            child: Text(
              "You can visualize, add, remove, edit licenses here.",
              style: Utilities.fonts.style(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
