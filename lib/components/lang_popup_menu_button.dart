import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LangPopupMenuButton extends StatelessWidget {
  const LangPopupMenuButton({
    Key? key,
    required this.lang,
    required this.onLangChanged,
    this.elevation = 0.0,
    this.opacity = 1.0,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);

  final String lang;
  final Function(String) onLangChanged;
  final double opacity;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        color: Colors.transparent,
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
                  color: Theme.of(context).textTheme.bodyText1?.color,
                ),
              ),
            ),
            onSelected: onLangChanged,
            itemBuilder: (context) => Utilities.lang
                .available()
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
