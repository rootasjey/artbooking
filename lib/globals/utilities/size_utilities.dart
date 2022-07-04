import 'package:flutter/widgets.dart';

class SizeUtils {
  const SizeUtils();

  /// Width limit between mobile & desktop screen size.
  final double mobileWidthTreshold = 700.0;

  /// Return true if the app's window is equal or less than the maximum
  /// mobile width.
  bool isMobileSize(BuildContext context) {
    final double pageWidth = MediaQuery.of(context).size.width;
    return pageWidth <= 700.0;
  }
}
