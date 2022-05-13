import 'package:artbooking/components/popup_menu/popup_menu_list_tile.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class LangPopupMenuButton extends StatelessWidget {
  const LangPopupMenuButton({
    Key? key,
    required this.lang,
    required this.onLangChanged,
    this.elevation = 0.0,
    this.opacity = 1.0,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(8.0),
    this.outlined = false,
  }) : super(key: key);

  /// If true, the button will be outlined. It will show a text button otherwise.
  final bool outlined;

  /// Current selected language.
  final String lang;

  /// Called when language has changed.
  final Function(String) onLangChanged;

  /// Widget's opacity.
  final double opacity;

  /// Widget's margin.
  final EdgeInsets margin;

  /// Widget's padding.
  final EdgeInsets padding;

  /// Widget's elevation.
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
            child: outlined ? outlinedButton(context) : textButton(context),
            onSelected: onLangChanged,
            itemBuilder: (context) => Utilities.lang.available().map(
              (languageCode) {
                final bool selected =
                    context.locale.languageCode == languageCode;

                final Color? color = selected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context)
                        .textTheme
                        .bodyText2
                        ?.color
                        ?.withOpacity(0.6);

                return PopupMenuItem(
                  value: languageCode,
                  child: PopupMenuListTile(
                    title: Text(
                      Utilities.lang.toFullString(languageCode),
                      style: Utilities.fonts.body(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    trailing: getTrailing(
                      selected,
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }

  Icon? getTrailing(bool selected) {
    final primary = Constants.colors.primary;

    if (selected) {
      return Icon(
        UniconsLine.check,
        color: primary,
      );
    }

    return null;
  }

  Widget outlinedButton(BuildContext context) {
    final Color baseColor =
        Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.4) ??
            Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 6.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.0),
        border: Border.all(
          color: baseColor.withOpacity(0.3),
          width: 2.0,
        ),
      ),
      child: Text(
        Utilities.lang.toFullString(lang),
        style: Utilities.fonts.body(
          color: baseColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget textButton(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        lang.toUpperCase(),
        style: Utilities.fonts.body(
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).textTheme.bodyText1?.color,
        ),
      ),
    );
  }
}
