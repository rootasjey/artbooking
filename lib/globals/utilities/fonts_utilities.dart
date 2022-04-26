import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fonts utilities.
/// Make it easier to work with online Google fonts.
///
/// See https://github.com/material-foundation/google-fonts-flutter/issues/35
class FontsUtilities {
  const FontsUtilities();

  static String? fontFamily = GoogleFonts.nunito().fontFamily;

  /// Return main text style.
  TextStyle style({
    FontWeight fontWeight = FontWeight.w400,
    double fontSize = 16.0,
    double? height,
    Color? color,
    Color? backgroundColor,
    TextDecoration? decoration,
    TextDecorationStyle? decorationStyle,
    Color? decorationColor,
    double? decorationThickness,
  }) {
    return GoogleFonts.nunito(
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      decoration: decoration,
      decorationStyle: decorationStyle,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
    );
  }

  /// Second text style.
  TextStyle style2({
    FontWeight fontWeight = FontWeight.w400,
    double fontSize = 16.0,
    double? height,
    Color? color,
    Color? backgroundColor,
    TextDecoration? decoration,
    TextDecorationStyle? decorationStyle,
    Color? decorationColor,
    double? decorationThickness,
  }) {
    return GoogleFonts.sourceCodePro(
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      decoration: decoration,
      decorationStyle: decorationStyle,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
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
