import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:artbooking/components/popup_menu_list_tile.dart';
import 'package:artbooking/types/globals/globals.dart';
import 'package:artbooking/types/theme_mode_menu_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// Button to control theme mode (dark/light/system).
class BrightnessButton extends StatelessWidget {
  const BrightnessButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ThemeModeMenuItem> items = [
      ThemeModeMenuItem(
        themeMode: AdaptiveThemeMode.system,
        leading: UniconsLine.brightness_half,
        title: "system".tr(),
      ),
      ThemeModeMenuItem(
        themeMode: AdaptiveThemeMode.dark,
        leading: UniconsLine.adjust_half,
        title: "dark".tr(),
      ),
      ThemeModeMenuItem(
        themeMode: AdaptiveThemeMode.light,
        leading: UniconsLine.bright,
        title: "light".tr(),
      ),
    ];

    final colors = Globals.constants.colors;
    final foregroundColor = colors.getForeground(context).withOpacity(0.6);

    return ValueListenableBuilder(
      valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
      builder: (context, AdaptiveThemeMode mode, child) {
        return PopupMenuButton<AdaptiveThemeMode>(
          icon: Icon(
            getIconThemeMode(mode),
            color: foregroundColor,
          ),
          tooltip: "brightness".tr(),
          onSelected: (AdaptiveThemeMode selectedThemeMode) {
            AdaptiveTheme.of(context).setThemeMode(selectedThemeMode);
          },
          itemBuilder: (context) {
            final primary = Globals.constants.colors.primary;

            return items.map((item) {
              final selected = mode == item.themeMode;

              return PopupMenuItem(
                value: item.themeMode,
                child: PopupMenuListTile(
                  leading: getLeading(
                    iconData: item.leading,
                    selected: selected,
                    defaultColor: foregroundColor,
                  ),
                  trailing: getTrailing(selected),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: selected ? primary : foregroundColor,
                    ),
                  ),
                ),
              );
            }).toList();
          },
        );
      },
    );
  }

  Icon getLeading({
    required IconData iconData,
    required bool selected,
    required Color defaultColor,
  }) {
    final primary = Globals.constants.colors.primary;
    return Icon(
      iconData,
      color: selected ? primary : defaultColor,
    );
  }

  Icon? getTrailing(bool selected) {
    final primary = Globals.constants.colors.primary;

    if (selected) {
      return Icon(
        UniconsLine.check,
        color: primary,
      );
    }

    return null;
  }

  IconData getIconThemeMode(AdaptiveThemeMode themeMode) {
    switch (themeMode) {
      case AdaptiveThemeMode.system:
        return UniconsLine.brightness_half;
      case AdaptiveThemeMode.dark:
        return UniconsLine.adjust_half;
      case AdaptiveThemeMode.light:
        return UniconsLine.bright;
      default:
        return UniconsLine.brightness;
    }
  }
}
