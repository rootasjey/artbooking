import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fonts utilities.
/// Make it easier to work with online Google fonts.
///
/// See https://github.com/material-foundation/google-fonts-flutter/issues/35
class FontsUtils {
  /// Return main text style for this app.
  static TextStyle getMainStyle({
    FontWeight fontWeight = FontWeight.w400,
    double fontSize = 16.0,
  }) {
    return GoogleFonts.raleway(
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}
