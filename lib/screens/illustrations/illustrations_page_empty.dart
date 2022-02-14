import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class IllustrationsPageEmpty extends StatelessWidget {
  const IllustrationsPageEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 40.0,
          left: 50.0,
          bottom: 100.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "lonely_there".tr(),
              style: Utilities.fonts.style(
                fontSize: 26.0,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Opacity(
              opacity: 0.4,
              child: Text(
                "illustrations_empty".tr(),
                style: Utilities.fonts.style(
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
