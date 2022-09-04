import 'dart:io';

import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

/// Utilities about in-out.
class IOUtilities {
  const IOUtilities();

  /// Return a path to save the passed file.
  Future<String> getSavingFilePath(
    BuildContext context, {
    required Reference fileRef,
    required Illustration illustration,
  }) async {
    final String pattern =
        Constants.allowedImageExt.map((final String ext) => ".$ext").join("|");

    final RegExp regExp = RegExp("($pattern)\$");
    final bool hasExtension = illustration.name.contains(regExp);

    final String suggestedNamed = hasExtension
        ? illustration.name
        : "${illustration.name}.${illustration.extension}";

    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      final Directory? directory = await getDownloadsDirectory();
      if (directory == null) {
        context.showErrorBar(
          content: Text("save_file_path_selection_canceled".tr()),
        );

        return "";
      }

      final String prefix = directory.absolute.path;
      return "$prefix/$suggestedNamed";
    }

    // ⚠️ Test on web.
    if (kIsWeb) {
      final String? path = await FilePicker.platform.saveFile(
        fileName: suggestedNamed,
      );

      if (path == null) {
        context.showErrorBar(
          content: Text("save_file_path_selection_canceled".tr()),
        );
      }
      return path ?? "";
    }

    return "";
  }

  /// Try to download an illustration to device local storage.
  /// The image file is saved in photos livrary on Android & iOS,
  /// in Downloads folder on Desktop (Linux, macOS, Windows) and web.
  Future<void> tryDownload(
    BuildContext context, {
    required Illustration illustration,
  }) async {
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        final bool? success = await GallerySaver.saveImage(
          illustration.links.original,
        );

        if (success == null || success == false) {
          context.showErrorBar(
            content: Text("illustration_download_failed".tr()),
          );

          return;
        }

        context.showSuccessBar(
          content: Text("illustration_download_completed".tr()),
        );

        return;
      }

      final Reference storageRef = FirebaseStorage.instance.ref();
      final Reference fileRef = storageRef.child(illustration.links.storage);

      final String path = await getSavingFilePath(
        context,
        fileRef: fileRef,
        illustration: illustration,
      );

      if (path.isEmpty) {
        return;
      }

      final File file = File(path);
      file.createSync(recursive: true);

      final DownloadTask task = fileRef.writeToFile(file);
      await task;

      context.showSuccessBar(
        content: Text("illustration_download_completed".tr()),
      );
    } catch (error) {
      Utilities.logger.i(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }
}
