import 'package:flutter/widgets.dart';

class SizeUtils {
  const SizeUtils();

  /// Return true if the app's window is equal or less than the maximum
  /// mobile width.
  bool isMobileSize(BuildContext context) {
    final pageWidth = MediaQuery.of(context).size.width;
    return pageWidth <= 700.0;
  }
}
