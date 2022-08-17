import 'package:artbooking/globals/constants/colors_constants.dart';
import 'package:artbooking/globals/constants/storage_keys_constants.dart';
import 'package:artbooking/globals/constants/links_constants.dart';

class Constants {
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  /// Allowed image file extension for illustrations.
  static const List<String> allowedImageExt = [
    "jpg",
    "jpeg",
    "png",
    "webp",
    "tiff",
  ];

  static final colors = ColorsConstants();
  static const links = const LinksContants();
  static const storageKeys = const StorageKeys();
}
