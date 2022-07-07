import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class LicensePageHeader extends StatelessWidget {
  const LicensePageHeader({
    Key? key,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    if (isMobileSize) {
      return SliverToBoxAdapter(child: Container());
    }

    return SliverPadding(
      padding: EdgeInsets.only(
          top: isMobileSize ? 24.0 : 68.0, left: isMobileSize ? 12.0 : 50.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Row(
            children: [
              IconButton(
                tooltip: "back".tr(),
                onPressed: () => Utilities.navigation.back(context),
                icon: Icon(UniconsLine.arrow_left),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
