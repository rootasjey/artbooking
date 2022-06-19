import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_data_ui_shape.dart';
import 'package:artbooking/types/enums/enum_separator_shape.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Separator shape card showing the shape name and form.
class SeparatorShapeCard extends StatelessWidget {
  const SeparatorShapeCard({
    Key? key,
    required this.separatorType,
    this.onTap,
    this.selected = false,
    this.shape = EnumDataUIShape.chip,
  }) : super(key: key);

  /// This widget is highlighted if true.
  final bool selected;

  /// Main data (separator type).
  final EnumSeparatorShape separatorType;

  /// The visual aspect of this widget.
  final EnumDataUIShape shape;

  /// Callback fired when this widget is tapped.
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    if (shape == EnumDataUIShape.card) {
      return cardWidth(context);
    }

    return chipWidget(context);
  }

  Widget cardWidth(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final BorderSide borderSide = selected
        ? BorderSide(color: primaryColor, width: 2.0)
        : BorderSide.none;

    return SizedBox(
      width: 150.0,
      height: 150.0,
      child: Card(
        elevation: onTap != null ? 4.0 : 0.0,
        color: Constants.colors.clairPink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: borderSide,
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Utilities.ui.getHeaderSeparatorIconData(
                    separatorType,
                  ),
                ),
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    "shape".tr(),
                    style: Utilities.fonts.body(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  "header_separator_shape"
                          ".${separatorType.name}"
                      .tr(),
                  style: Utilities.fonts.body(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget chipWidget(
    BuildContext context, {
    double opacity = 1.0,
  }) {
    if (onTap == null) {
      return Chip(
        avatar: Icon(
          Utilities.ui.getHeaderSeparatorIconData(
            separatorType,
          ),
          size: 16.0,
          color: Colors.black38,
        ),
        label: Text(
          "${"shape".tr()}: ${"header_separator_shape"
              ".${separatorType.name}".tr()}",
          style: Utilities.fonts.body(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
      );
    }

    return ActionChip(
      avatar: Icon(
        Utilities.ui.getHeaderSeparatorIconData(
          separatorType,
        ),
        size: 16.0,
        color: Colors.black38,
      ),
      label: Text(
        "${"shape".tr()}: ${"header_separator_shape"
            ".${separatorType.name}".tr()}",
        style: Utilities.fonts.body(),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      onPressed: () => onTap?.call(),
    );
  }
}
