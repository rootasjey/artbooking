import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:unicons/unicons.dart';

class AppIconScreenshotPage extends StatefulWidget {
  const AppIconScreenshotPage({Key? key}) : super(key: key);

  @override
  State<AppIconScreenshotPage> createState() => _AppIconScreenshotPageState();
}

class _AppIconScreenshotPageState extends State<AppIconScreenshotPage> {
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final double roundedRectValue = 62.0;
    final double height = 340.0;
    final double width = 340.0;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: tryTakeScreenshot,
        icon: Icon(UniconsLine.camera),
        label: Text("screenshot"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(roundedRectValue + 16),
              border: Border.all(
                // color: Constants.colors.tertiary,
                color: Colors.amber.shade700,
                width: 16.0,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(roundedRectValue),
              child: Image.asset(
                "assets/images/app_icon/new_app_poster.png",
                height: height,
                width: width,
                fit: BoxFit.cover,
              ),
            ),
            height: height,
            width: width,
          ),
        ),
      ),
    );
  }

  void tryTakeScreenshot() async {
    final Uint8List? resultImage = await screenshotController.capture();
    if (resultImage == null) {
      context.showErrorBar(
        content: Text("download_file_error".tr()),
      );

      return;
    }

    final fileCross = FilePickerCross(
      resultImage,
      fileExtension: "png",
      type: FileTypeCross.image,
    );

    fileCross.exportToStorage(
      fileName: "app_icon-${DateTime.now().second}.png",
    );
  }
}
