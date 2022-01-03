import 'package:artbooking/components/upload_window/header_buttons.dart';
import 'package:artbooking/components/upload_window/header_subtitle.dart';
import 'package:artbooking/components/upload_window/header_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadWindowHeader extends ConsumerWidget {
  const UploadWindowHeader({
    Key? key,
    required this.percent,
    required this.abortedTaskCount,
    required this.successTaskCount,
    required this.runningTaskCount,
    required this.pausedTaskCount,
    required this.hasUncompletedTask,
  }) : super(key: key);

  final int percent;
  final int abortedTaskCount;
  final int successTaskCount;
  final int runningTaskCount;
  final int pausedTaskCount;
  final bool hasUncompletedTask;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int remainingTaskCount = runningTaskCount + pausedTaskCount;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderTitle(
                  remainingTaskCount: remainingTaskCount,
                  hasUncompletedTasks: hasUncompletedTask,
                ),
                HeaderSubtitle(
                  percent: percent,
                  successTaskCount: successTaskCount,
                  runningTaskCount: runningTaskCount,
                  hasUncompletedTasks: hasUncompletedTask,
                  pausedTaskCount: pausedTaskCount,
                  abortedTaskCount: abortedTaskCount,
                ),
              ],
            ),
          ),
          HeaderButtons(
            runningTaskCount: runningTaskCount,
            hasUncompletedTask: hasUncompletedTask,
            pausedTaskCount: pausedTaskCount,
          ),
        ],
      ),
    );
  }
}
