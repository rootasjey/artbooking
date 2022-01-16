import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/components/texts/text_icon.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ActivityPageUsedStorage extends StatelessWidget {
  const ActivityPageUsedStorage({
    Key? key,
    required this.usedSpace,
  }) : super(key: key);

  final String usedSpace;

  @override
  Widget build(BuildContext context) {
    return TextIcon(
      icon: Icon(
        UniconsLine.database,
        size: 24.0,
      ),
      richText: RichText(
        text: TextSpan(
          style: TextStyle(
            color:
                Theme.of(context).textTheme.bodyText1?.color?.withOpacity(0.6),
            fontSize: 16.0,
          ),
          children: [
            TextSpan(text: "space_total_used".tr()),
            TextSpan(
              text: " $usedSpace",
              style: Utilities.fonts.style(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
