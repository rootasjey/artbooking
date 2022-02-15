import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class IllustrationPageFab extends StatelessWidget {
  const IllustrationPageFab({
    Key? key,
    required this.isVisible,
    this.onShowEditMetadataPanel,
  }) : super(key: key);

  final bool isVisible;
  final Function()? onShowEditMetadataPanel;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return Container();
    }

    return FloatingActionButton.extended(
      onPressed: onShowEditMetadataPanel,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      icon: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Icon(UniconsLine.edit_alt),
      ),
      label: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "edit".tr(),
          style: Utilities.fonts.style(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
