import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fonts utilities.
/// Make it easier to work with online Google fonts.
///
/// See https://github.com/material-foundation/google-fonts-flutter/issues/35
class FontsUtilities {
  const FontsUtilities();

  static String? fontFamily = GoogleFonts.nunito().fontFamily;

  /// Return main text style for this app.
  TextStyle style({
    FontWeight fontWeight = FontWeight.w400,
    double fontSize = 16.0,
    double? height,
    Color? color,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.nunito(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      decoration: decoration,
    );
  }

  TextStyle titleStyle({
    FontWeight fontWeight = FontWeight.w400,
    double fontSize = 16.0,
    double? height,
    Color? color,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.pacifico(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      decoration: decoration,
    );
  }
}
