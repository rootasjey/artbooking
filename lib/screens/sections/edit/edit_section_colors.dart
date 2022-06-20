import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/sections/edit/color_card_picker.dart';
import 'package:artbooking/types/enums/enum_data_ui_shape.dart';
import 'package:artbooking/types/named_color.dart';
import 'package:artbooking/types/section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EditSectionColors extends StatelessWidget {
  const EditSectionColors({
    Key? key,
    required this.section,
    this.onBackgroundColorChanged,
    this.onTextColorChanged,
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  /// External padding (blank space around this widget).
  final EdgeInsets margin;

  /// Main data to retrieve the colors from.
  final Section section;

  /// Callback event fired when this section's background color is updated.
  final void Function(NamedColor)? onBackgroundColorChanged;

  /// Callback event fired when this section's text color is updated.
  final void Function(NamedColor)? onTextColorChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInY(
            beginY: 12.0,
            delay: Duration(milliseconds: 75),
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  "colors".tr().toUpperCase(),
                  style: Utilities.fonts.body3(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: [
              FadeInY(
                beginY: 12.0,
                delay: Duration(milliseconds: 100),
                child: ColorCardPicker(
                  shape: EnumDataUIShape.chip,
                  name: "background_color_default".tr(),
                  dialogTextTitle: "background_color_update".tr(),
                  dialogTextSubtitle: "section_background_color_choose".tr(),
                  selectedColor: section.backgroundColor,
                  onValueChanged: onBackgroundColorChanged,
                  margin: const EdgeInsets.only(left: 6.0),
                ),
              ),
              FadeInY(
                beginY: 12.0,
                delay: Duration(milliseconds: 125),
                child: ColorCardPicker(
                  shape: EnumDataUIShape.chip,
                  dialogTextTitle: "text_color_update".tr(),
                  dialogTextSubtitle: "text_color_choose".tr(),
                  name: "text_color_default".tr(),
                  selectedColor: section.textColor,
                  onValueChanged: onTextColorChanged,
                  margin: const EdgeInsets.only(left: 6.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
