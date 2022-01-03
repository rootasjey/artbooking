import 'package:artbooking/types/globals/language.dart';
import 'package:artbooking/types/globals/size_utils.dart';

class GlobalsUtils {
  final size = SizeUtils();
  final lang = Language();

  String getStringWithUnit(int usedBytes) {
    if (usedBytes < 1000) {
      return '$usedBytes bytes';
    }

    if (usedBytes < 1000000) {
      return '$usedBytes KB';
    }

    if (usedBytes < 1000000000) {
      return '$usedBytes MB';
    }

    if (usedBytes < 1000000000000) {
      return '$usedBytes GB';
    }

    if (usedBytes < 1000000000000000) {
      return '$usedBytes TB';
    }

    return '$usedBytes PB';
  }
}
