import 'package:artbooking/components/sheet_header.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class EditItemSheetHeader extends StatelessWidget {
  const EditItemSheetHeader({
    Key? key,
    required this.titleValue,
    this.heroTitleTag = "",
    this.subtitleValue = "",
  }) : super(key: key);

  /// If provided, will try to make a hero transition with the title.
  final String heroTitleTag;

  /// Title's string.
  final String titleValue;

  /// Subtitle's string.
  final String subtitleValue;

  @override
  Widget build(BuildContext context) {
    return SheetHeader(
      heroTitleTag: heroTitleTag,
      margin: const EdgeInsets.only(left: 12.0, top: 24.0),
      subtitle: subtitleValue,
      title: titleValue,
      tooltip: "close".tr(),
    );
  }
}
