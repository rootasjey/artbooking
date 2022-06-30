import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class IllustrationPageFab extends StatelessWidget {
  const IllustrationPageFab({
    Key? key,
    this.isOwner = false,
    this.show = false,
    this.onCreateNewVersion,
    this.onDownload,
  }) : super(key: key);

  /// True if the current authenticated user- if any -
  /// is the owner of this illustration.
  final bool isOwner;

  /// This widget is displayed if true.
  final bool show;

  /// Callback to update the current illustration.
  final Function()? onCreateNewVersion;

  /// Callback to download the current illustration.
  final Function()? onDownload;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          onPressed: onDownload,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          icon: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(UniconsLine.download_alt),
          ),
          label: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "download".tr(),
              style: Utilities.fonts.body(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (isOwner)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: Colors.amber.shade700,
              onPressed: onCreateNewVersion,
              child: Icon(UniconsLine.upload_alt),
            ),
          ),
      ],
    );
  }
}
