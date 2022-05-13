import 'package:artbooking/components/cards/separator_color_card.dart';
import 'package:artbooking/components/cards/separator_shape_card.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/header_separator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SectionPageHeaderSeparator extends StatelessWidget {
  const SectionPageHeaderSeparator({
    Key? key,
    required this.headerSeparator,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final HeaderSeparator headerSeparator;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "header_separator".tr(),
                style: Utilities.fonts.body(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Wrap(
            children: [
              SeparatorShapeCard(
                separatorType: headerSeparator.shape,
              ),
              SeparatorColorCard(
                color: Color(headerSeparator.color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
