import 'package:artbooking/components/dialogs/colors_selector.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/named_color.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EditSectionBackground extends StatelessWidget {
  const EditSectionBackground({
    Key? key,
    required this.backgroundColor,
    this.onValueChanged,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final EdgeInsets padding;
  final int backgroundColor;
  final void Function(NamedColor)? onValueChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        width: 140.0,
        height: 140.0,
        child: Card(
          elevation: 4.0,
          color: Color(backgroundColor),
          child: InkWell(
            onTap: () => showColorDialog(context),
            child: Opacity(
              opacity: 0.6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "background_color_default".tr(),
                    style: Utilities.fonts.style(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showColorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ThemedDialog(
          useRawDialog: true,
          titleValue: "Update background color",
          body: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 360.0,
              maxWidth: 400.0,
            ),
            child: ColorsSelector(
              subtitle: "section_background_color_chose".tr(),
              selectedColorInt: backgroundColor,
              onTapNamedColor: (NamedColor namedColor) {
                onValueChanged?.call(namedColor);
                Beamer.of(context).popRoute();
              },
            ),
          ),
          textButtonValidation: "close".tr(),
          onCancel: Beamer.of(context).popRoute,
          onValidate: Beamer.of(context).popRoute,
        );
      },
    );
  }
}
