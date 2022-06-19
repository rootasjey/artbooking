import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_data_ui_shape.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SeparatorColorCard extends StatelessWidget {
  const SeparatorColorCard({
    Key? key,
    required this.color,
    this.onTap,
    this.shape = EnumDataUIShape.chip,
  }) : super(key: key);

  /// Color value.
  final Color color;

  /// The visual aspect of this widget.
  final EnumDataUIShape shape;

  /// Callback fired when this widget is tapped.
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    if (shape == EnumDataUIShape.card) {
      return cardWidget(context);
    }

    return chipWidget(context);
  }

  Widget cardWidget(BuildContext context) {
    final double luminance = color.computeLuminance();
    final Color foreground = luminance < 0.5 ? Colors.white : Colors.black;

    return SizedBox(
      width: 150.0,
      height: 150.0,
      child: Card(
        elevation: onTap != null ? 4.0 : 0.0,
        color: color,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(UniconsLine.palette, color: foreground),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    "color".tr(),
                    style: Utilities.fonts.body(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget chipWidget(BuildContext context) {
    final double luminance = color.computeLuminance();
    final Color foreground = luminance < 0.5 ? Colors.white : Colors.black;

    if (onTap == null) {
      return Chip(
        backgroundColor: color,
        avatar: Icon(
          UniconsLine.palette,
          color: foreground,
          size: 16.0,
        ),
        label: Text(
          "color".tr(),
          style: Utilities.fonts.body(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
      );
    }

    return ActionChip(
      backgroundColor: color,
      avatar: Icon(
        UniconsLine.palette,
        color: foreground,
        size: 16.0,
      ),
      label: Text(
        "color".tr(),
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
