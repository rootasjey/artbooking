import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:unicons/unicons.dart';

class LicensePageDates extends StatelessWidget {
  const LicensePageDates({
    Key? key,
    required this.createdAt,
    required this.updatedAt,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final DateTime createdAt;
  final DateTime updatedAt;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Opacity(
        opacity: 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(UniconsLine.play),
                  ),
                  Text(
                    "date_created_ago".tr(args: [Jiffy(createdAt).fromNow()]),
                    style: Utilities.fonts.body(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(UniconsLine.arrow_circle_up),
                ),
                Text(
                  "date_updated_ago".tr(args: [Jiffy(updatedAt).fromNow()]),
                  style: Utilities.fonts.body(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
