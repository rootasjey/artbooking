import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class ColorsConstants {
  /// Color for statistics.
  final Color activity = Colors.red;

  final Color clairPink = Color(0xFFf5eaf9);

  final Color dark = Color(0xFF303030);
  final Color lightBackground = Color(0xFfe3e6ec);

  /// Color for posts.
  final Color posts = Colors.blue.shade700;

  /// Primary application's color.
  final Color primary = Color(0xFF796AD2);

  /// Color for projects.
  final Color projects = Colors.amber;

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
  final Color settings = Colors.teal;

  /// Color for profile.
  final Color profile = Colors.indigo;

  /// Secondary application's color.
  Color secondary = Colors.pink;

  final Color validation = Colors.green;

  Color getBackgroundColor(BuildContext context) {
    if (AdaptiveTheme.of(context).brightness == Brightness.dark) {
      return dark;
    }

    return lightBackground;
  }

  Color getForeground(BuildContext context) {
    if (AdaptiveTheme.of(context).brightness == Brightness.dark) {
      return Colors.white;
    }

    return Colors.black;
  }
}
