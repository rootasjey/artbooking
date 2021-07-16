import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'colors.g.dart';

class StateColors = StateColorsBase with _$StateColors;

abstract class StateColorsBase with Store {
  @observable
  Color background = Colors.white;

  @observable
  Color foreground = Colors.black;

  /// Primary application's color.
  @observable
  Color primary = Color(0xFF796AD2);

  /// Secondary application's color.
  @observable
  Color secondary = Colors.pink;

  final Color dark = Color(0xFF303030);
  final Color deletion = Color(0xfff55c5c);
  final Color light = Color(0xFFEEEEEE);
  final Color lightBackground = Color(0xFfe3e6ec);
  final Color validation = Color(0xff38d589);
  final Color clairPink = Color(0xFFf5eaf9);

  /// Color for statistics.
  final Color activity = Colors.red;

  /// Color for books.
  final Color books = Colors.blue.shade700;

  /// Color for challenges.
  final Color challenges = Colors.amber;

  /// Color for contests.
  final Color contests = Colors.indigo;

  /// Color for illustrations.
  final Color illustrations = Color(0xFF796AD2);

  /// Color for galleries.
  final Color galleries = Colors.green;

  /// Color for settings.
  final Color settings = Colors.lime;

  ThemeData? themeData;

  @action
  void refreshTheme(Brightness? brightness) {
    if (brightness == Brightness.dark) {
      foreground = Colors.white;
      background = Colors.black;
      return;
    }

    foreground = Colors.black;
    background = Colors.white;
  }

  @action
  void setPrimaryColor(Color color) {
    primary = color;
  }

  @action
  void setSecondaryColor(Color color) {
    secondary = color;
  }
}

final stateColors = StateColors();
