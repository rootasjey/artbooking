import 'package:artbooking/components/upload_panel/upload_panel_header_buttons.dart';
import 'package:artbooking/components/upload_panel/upload_panel_header_subtitle.dart';
import 'package:artbooking/components/upload_panel/upload_panel_header_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Header of `UploadPanel`.
class UploadWindowHeader extends ConsumerWidget {
  const UploadWindowHeader({
    Key? key,
    required this.abortedTaskCount,
    required this.pausedTaskCount,
    required this.pendingTaskCount,
    required this.percent,
    required this.runningTaskCount,
    required this.successTaskCount,
  }) : super(key: key);

  final int abortedTaskCount;
  final int pausedTaskCount;
  final int pendingTaskCount;
  final int percent;
  final int runningTaskCount;
  final int successTaskCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UploadPanelHeaderTitle(
                  pendingTaskCount: pendingTaskCount,
                ),
                UploadPanelHeaderSubtitle(
                  abortedTaskCount: abortedTaskCount,
                  pausedTaskCount: pausedTaskCount,
                  pendingTaskCount: pendingTaskCount,
                  percent: percent,
                  runningTaskCount: runningTaskCount,
                  successTaskCount: successTaskCount,
                ),
              ],
            ),
          ),
          UploadPanelHeaderButtons(
            runningTaskCount: runningTaskCount,
            pausedTaskCount: pausedTaskCount,
            pendingTaskCount: pendingTaskCount,
          ),
        ],
      ),
    );
  }
}
