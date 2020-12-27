import 'package:artbooking/router/route_names.dart';
import 'package:artbooking/screens/upload.dart';
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

    if (ModalRoute.of(context).settings.name == UploadRoute) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => Upload()),
    );
  }
}

final appUploadManager = UploadManager();
