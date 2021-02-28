import 'package:artbooking/router/app_router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadManager {
  List<PlatformFile> selectedFiles = [];

  /// A "select file/folder" window will appear. User will have to choose a file.
  /// This file will be then read, and uploaded to firebase storage;
  Future pickImage(BuildContext context) async {
    final pickerResult = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (pickerResult == null) {
      return;
    }

    selectedFiles = pickerResult.files;

    if (context.router.current.name == AddIllustrationRoute.name) {
      return;
    }

    context.router.root.push(
      DashboardPageRoute(
        children: [AddIllustrationRoute()],
      ),
    );
  }
}

final appUploadManager = UploadManager();
