import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/components/texts/text_icon.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:unicons/unicons.dart';

class ActivityPageMemberSince extends StatelessWidget {
  const ActivityPageMemberSince({
    Key? key,
    required this.createdAt,
  }) : super(key: key);

  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    if (createdAt == null) {
      return Container();
    }

    return TextIcon(
      icon: Icon(
        UniconsLine.clock,
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
            TextSpan(text: "member_since".tr()),
            TextSpan(
              text: " ${Jiffy(createdAt).format('MMMM yyyy')}",
              style: Utilities.fonts.body(
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
