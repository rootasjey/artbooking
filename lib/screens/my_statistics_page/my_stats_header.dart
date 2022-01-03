import 'package:artbooking/utils/fonts.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class MyStatsHeader extends StatelessWidget {
  const MyStatsHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 54.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "statistics".tr().toUpperCase(),
                style: FontsUtils.mainStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
