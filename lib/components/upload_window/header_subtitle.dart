import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeaderSubtitle extends ConsumerWidget {
  const HeaderSubtitle({
    Key? key,
    required this.percent,
    required this.abortedTaskCount,
    required this.successTaskCount,
    required this.runningTaskCount,
    required this.pausedTaskCount,
    required this.hasUncompletedTasks,
  }) : super(key: key);

  final int percent;
  final int abortedTaskCount;
  final int successTaskCount;
  final int runningTaskCount;
  final int pausedTaskCount;
  final bool hasUncompletedTasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (percent == 0 && hasUncompletedTasks) {
      return SizedBox(
        width: 200.0,
        child: LinearProgressIndicator(
          minHeight: 2.0,
        ),
      );
    }

    return Opacity(
      opacity: 0.6,
      child: Text(
        getWindowSubtitle(),
        style: Utilities.fonts.style(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String getWindowSubtitle() {
    if (!hasUncompletedTasks) {
      String text = "illustration_upload_count".plural(
        successTaskCount,
      );

      if (abortedTaskCount > 0) {
        text += " ";
        text += "illustration_upload_aborted_count".plural(
          abortedTaskCount,
        );
      }

      return text;
    }

    return "${percent} %";
  }
}
