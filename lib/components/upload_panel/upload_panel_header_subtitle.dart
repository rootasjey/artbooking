import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadPanelHeaderSubtitle extends ConsumerWidget {
  const UploadPanelHeaderSubtitle({
    Key? key,
    required this.percent,
    required this.abortedTaskCount,
    required this.successTaskCount,
    required this.runningTaskCount,
    required this.pausedTaskCount,
    required this.pendingTaskCount,
  }) : super(key: key);

  final int percent;
  final int abortedTaskCount;
  final int successTaskCount;
  final int runningTaskCount;
  final int pausedTaskCount;
  final int pendingTaskCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (percent == 0 && pendingTaskCount > 0) {
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
        style: Utilities.fonts.body(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String getWindowSubtitle() {
    if (pendingTaskCount == 0) {
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
