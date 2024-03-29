import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SectionPageTitle extends StatelessWidget {
  const SectionPageTitle({
    Key? key,
    required this.sectionId,
  }) : super(key: key);

  final String sectionId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: sectionId,
          child: Text(
            "section_name.${sectionId}".tr(),
            style: Utilities.fonts.body3(
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FadeInY(
          beginY: 12.0,
          delay: Duration(milliseconds: 5),
          child: Container(
            width: 500.0,
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "section_description.${sectionId}".tr(),
                style: Utilities.fonts.body(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
