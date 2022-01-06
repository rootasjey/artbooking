import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class HeaderTitle extends StatelessWidget {
  const HeaderTitle({
    Key? key,
    required this.hasUncompletedTasks,
    required this.remainingTaskCount,
  }) : super(key: key);

  final bool hasUncompletedTasks;
  final int remainingTaskCount;

  @override
  Widget build(BuildContext context) {
    final String textValue = hasUncompletedTasks
        ? "illustration_uploading_files".tr(
            args: [remainingTaskCount.toString()],
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
