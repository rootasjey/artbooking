import 'package:artbooking/globals/utilities/language_utilities.dart';
import 'package:artbooking/globals/utilities/size_utilities.dart';

class Utilities {
  static const size = const SizeUtils();
  static const lang = const LanguageUtilities();

  static String getStringWithUnit(int usedBytes) {
    if (usedBytes < 1000) {
      return '$usedBytes bytes';
    }

    if (usedBytes < 1000000) {
      return '${usedBytes / 1000} KB';
    }

    if (usedBytes < 1000000000) {
      return '${usedBytes / 1000000} MB';
    }

    if (usedBytes < 1000000000000) {
      return '${usedBytes / 1000000000} GB';
    }

    if (usedBytes < 1000000000000000) {
      return '${usedBytes / 1000000000000} TB';
    }

    return '${usedBytes / 1000000000000000} PB';
  }
}
