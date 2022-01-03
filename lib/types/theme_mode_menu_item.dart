import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/widgets.dart';

class ThemeModeMenuItem {
  final AdaptiveThemeMode themeMode;
  final IconData leading;
  final String title;

  ThemeModeMenuItem({
    required this.themeMode,
    required this.leading,
    required this.title,
  });
}
