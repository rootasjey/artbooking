import 'package:artbooking/state/colors.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/language.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LangPopupMenuButton extends StatelessWidget {
  final String lang;
  final Function(String) onLangChanged;
  final double opacity;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double elevation;
  final Color? color;

  const LangPopupMenuButton({
    Key? key,
    required this.lang,
    required this.onLangChanged,
    this.color,
    this.elevation = 0.0,
    this.opacity = 1.0,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        color: color,
        elevation: elevation,
        borderRadius: BorderRadius.circular(4.0),
        child: Opacity(
          opacity: opacity,
          child: PopupMenuButton<String>(
            tooltip: "language_change".tr(),
            child: Padding(
              padding: padding,
              child: Text(
                lang.toUpperCase(),
                style: FontsUtils.mainStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: stateColors.foreground,
                ),
              ),
            ),
            onSelected: onLangChanged,
            itemBuilder: (context) => Language.available()
                .map(
                  (value) => PopupMenuItem(
                    value: value,
                    child: Text(value.toUpperCase()),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
