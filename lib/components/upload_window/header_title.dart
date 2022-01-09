import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class HeaderTitle extends StatelessWidget {
  const HeaderTitle({
    Key? key,
    required this.pendingTaskCount,
  }) : super(key: key);

  final int pendingTaskCount;

  @override
  Widget build(BuildContext context) {
    final String textValue = pendingTaskCount > 0
        ? "illustration_uploading_files".plural(
            pendingTaskCount,
          )
        : "All done.";

    return Text(
      textValue,
      style: Utilities.fonts.style(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
