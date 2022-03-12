import 'package:artbooking/components/sheet_header.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class EditItemSheetHeader extends StatelessWidget {
  const EditItemSheetHeader({
    Key? key,
    required this.itemId,
    required this.itemName,
    this.subtitleCreate = "",
    this.subtitleEdit = "",
  }) : super(key: key);

  final String itemId;
  final String itemName;
  final String subtitleCreate;
  final String subtitleEdit;

  @override
  Widget build(BuildContext context) {
    final String headerTitleValue =
        itemName.isEmpty ? "new".tr() : "edit".tr() + " $itemName";

    final String headerSubtitle =
        itemId.isEmpty ? subtitleCreate : subtitleEdit;

    return SheetHeader(
      title: headerTitleValue,
      tooltip: "close".tr(),
      subtitle: headerSubtitle,
    );
  }
}
