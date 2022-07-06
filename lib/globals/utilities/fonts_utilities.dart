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
  TextStyle body({
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
  TextStyle body2({
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

  /// Secondary title's font style.
  /// Eventually for blog post title.
  TextStyle body3({
    FontWeight fontWeight = FontWeight.w400,
    double fontSize = 16.0,
    double? height,
    Color? color,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.robotoSlab(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      decoration: decoration,
    );
  }

  /// Return a colored dot aq a Widget.
  /// Useful in bullet list or as a separator.
  Widget coloredDot({
    Color? color,
    double opacity = 0.3,
    double size = 16.0,
    FontWeight weight = FontWeight.w800,
  }) {
    return Opacity(
      opacity: opacity,
      child: Text(
        " • ",
        style: body(
          color: color,
          fontSize: size,
          fontWeight: weight,
        ),
      ),
    );
  }

  /// Primary title's font style.
  TextStyle title({
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

  /// Tertiary title's font style.
  /// Eventually for blog post title.
  TextStyle title2({
    FontWeight fontWeight = FontWeight.w400,
    double fontSize = 16.0,
    double? height,
    Color? color,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.oleoScriptSwashCaps(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      decoration: decoration,
    );
  }

  /// Can be used for blog post body.
  TextStyle title3({
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
    return GoogleFonts.playfairDisplay(
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
}
