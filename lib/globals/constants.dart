import 'package:artbooking/globals/constants/colors_constants.dart';
import 'package:artbooking/globals/constants/storage_keys_constants.dart';
import 'package:artbooking/globals/constants/links_constants.dart';

class Constants {
  /// Current application version.
  static const String appVersion = '1.0.0';

  /// Application build number.
  static const int appBuildNumber = 1;

  /// Allowed image file extension for illustrations.
  static const List<String> allowedImageExt = [
    "jpg",
    "jpeg",
    "png",
    "webp",
    "tiff",
  ];

  /// Maximum allowed file size to be uploaded.
  static const int maxFileSize = 25000000;

  /// All necessary colors for the app.
  static final colors = ColorsConstants();

  /// App external links.
  static const links = const LinksContants();

  /// Unique keys to store and retrieve data from local storage.
  static const storageKeys = const StorageKeys();
}
