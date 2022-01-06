import 'package:artbooking/globals/utilities/cloud_utilities.dart';
import 'package:artbooking/globals/utilities/date_utilities.dart';
import 'package:artbooking/globals/utilities/flash_utilities.dart';
import 'package:artbooking/globals/utilities/fonts_utilities.dart';
import 'package:artbooking/globals/utilities/search_utilities.dart';
import 'package:artbooking/globals/utilities/snack_utilities.dart';
import 'package:artbooking/globals/utilities/storage_utilities.dart';
import 'package:artbooking/globals/utilities/language_utilities.dart';
import 'package:artbooking/globals/utilities/size_utilities.dart';

class Utilities {
  static const cloud = const CloudUtilities();
  static const date = const DateUtilities();
  static const flash = const FlashUtilities();
  static const fonts = const FontsUtilities();
  static const lang = const LanguageUtilities();
  static const search = const SearchUtilities();
  static const size = const SizeUtils();
  static const snack = const SnackUtilities();
  static const storage = const StorageUtilities();

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
