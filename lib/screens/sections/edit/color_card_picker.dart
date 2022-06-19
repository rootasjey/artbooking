import 'package:artbooking/components/dialogs/colors_selector.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_data_ui_shape.dart';
import 'package:artbooking/types/named_color.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ColorCardPicker extends StatelessWidget {
  const ColorCardPicker({
    Key? key,
    required this.selectedColor,
    required this.name,
    required this.dialogTextTitle,
    required this.dialogTextSubtitle,
    this.onValueChanged,
    this.margin = EdgeInsets.zero,
    this.shape = EnumDataUIShape.card,
  }) : super(key: key);

  /// External padding (blank space around this widget).
  final EdgeInsets margin;

  /// The visual aspect of this widget.
  final EnumDataUIShape shape;

  /// Current selected color integer.
  final int selectedColor;

  /// To which element this color belongs to?
  final String name;
  final String dialogTextTitle;
  final String dialogTextSubtitle;

  /// Callback fired when the color is updated.
  final void Function(NamedColor)? onValueChanged;

  @override
  Widget build(BuildContext context) {
    final luminance = Color(selectedColor).computeLuminance();
    final Color textColor = luminance > 0.5 ? Colors.black : Colors.white;

    final Function()? onTap =
        onValueChanged != null ? () => showColorDialog(context) : null;

    if (shape == EnumDataUIShape.card) {
      return Padding(
        padding: margin,
        child: SizedBox(
          width: 140.0,
          height: 140.0,
          child: Card(
            elevation: 4.0,
            color: Color(selectedColor),
            child: InkWell(
              onTap: onTap,
              child: Opacity(
                opacity: 0.6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      name,
                      style: Utilities.fonts.body(
                        color: textColor,
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

    return chipWidget(onTap: onTap);
  }

  Widget chipWidget({Function()? onTap}) {
    if (onTap == null) {
      return Padding(
        padding: margin,
        child: Chip(
          elevation: 0.0,
          avatar: CircleAvatar(
            backgroundColor: Color(selectedColor),
          ),
          label: Opacity(
            opacity: 0.8,
            child: Text(
              name,
              style: Utilities.fonts.body(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: margin,
      child: ActionChip(
        elevation: 2.0,
        onPressed: onTap,
        avatar: CircleAvatar(
          backgroundColor: Color(selectedColor),
        ),
        label: Opacity(
          opacity: 0.8,
          child: Text(
            name,
            style: Utilities.fonts.body(
              fontWeight: FontWeight.w600,
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
          titleValue: dialogTextTitle,
          body: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 420.0,
              maxWidth: 400.0,
            ),
            child: ColorsSelector(
              subtitle: dialogTextSubtitle,
              selectedColorInt: selectedColor,
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
