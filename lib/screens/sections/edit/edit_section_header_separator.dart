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
    this.margin = EdgeInsets.zero,
    required this.headerSeparator,
    this.onShowHeaderSeparatorDialog,
    this.editMode = false,
  }) : super(key: key);

  /// Values will be editable if true.
  final bool editMode;

  /// External padding (blank space around this widget).
  final EdgeInsets margin;

  /// Selected section's header separator.
  final HeaderSeparator headerSeparator;

  /// Callback event fired when this section's header separator is updated.
  final void Function(
    EnumHeaderSeparatorTab initialTab,
  )? onShowHeaderSeparatorDialog;

  @override
  Widget build(BuildContext context) {
    final void Function()? onTapShapeCard = editMode
        ? () => onShowHeaderSeparatorDialog?.call(
              EnumHeaderSeparatorTab.shape,
            )
        : null;

    final void Function()? onTapColorCard = editMode
        ? () => onShowHeaderSeparatorDialog?.call(
              EnumHeaderSeparatorTab.color,
            )
        : null;

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "header_separator".tr().toUpperCase(),
                style: Utilities.fonts.body3(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              SeparatorShapeCard(
                separatorType: headerSeparator.shape,
                onTap: onTapShapeCard,
              ),
              SeparatorColorCard(
                color: Color(headerSeparator.color),
                onTap: onTapColorCard,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
