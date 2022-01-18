import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class LicensePageHeader extends StatelessWidget {
  const LicensePageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 68.0, left: 50.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Row(
            children: [
              IconButton(
                tooltip: "back".tr(),
                onPressed: Beamer.of(context).popRoute,
                icon: Icon(UniconsLine.arrow_left),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
