import 'package:artbooking/components/cards/separator_color_card.dart';
import 'package:artbooking/components/cards/separator_shape_card.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_header_separator_tab.dart';
import 'package:artbooking/types/header_separator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EditSectionHeaderSeparator extends StatelessWidget {
  const EditSectionHeaderSeparator({
    Key? key,
    this.padding = EdgeInsets.zero,
    required this.headerSeparator,
    this.onShowHeaderSeparatorDialog,
  }) : super(key: key);

  final EdgeInsets padding;
  final HeaderSeparator headerSeparator;
  final void Function(
    EnumHeaderSeparatorTab initialTab,
  )? onShowHeaderSeparatorDialog;

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
                onTap: () => onShowHeaderSeparatorDialog?.call(
                  EnumHeaderSeparatorTab.shape,
                ),
              ),
              SeparatorColorCard(
                color: Color(headerSeparator.color),
                onTap: () => onShowHeaderSeparatorDialog?.call(
                  EnumHeaderSeparatorTab.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
