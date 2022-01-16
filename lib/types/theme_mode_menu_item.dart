import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/widgets.dart';

class ThemeModeMenuItem {
  ThemeModeMenuItem({
    required this.themeMode,
    required this.leading,
    required this.title,
  });

  final AdaptiveThemeMode themeMode;
  final IconData leading;
  final String title;
}
