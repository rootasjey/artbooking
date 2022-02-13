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
            Padding(
              padding: const EdgeInsets.only(
                bottom: 12.0,
              ),
              child: Text(
                "lonely_there".tr(),
                style: TextStyle(
                  fontSize: 32.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16.0,
                // top: 24.0,
              ),
              child: Opacity(
                opacity: 0.4,
                child: Text(
                  "illustrations_empty".tr(),
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
