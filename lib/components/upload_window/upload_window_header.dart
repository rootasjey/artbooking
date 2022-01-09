import 'package:artbooking/components/upload_window/header_buttons.dart';
import 'package:artbooking/components/upload_window/header_subtitle.dart';
import 'package:artbooking/components/upload_window/header_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                HeaderTitle(
                  pendingTaskCount: pendingTaskCount,
                ),
                HeaderSubtitle(
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
          HeaderButtons(
            runningTaskCount: runningTaskCount,
            pausedTaskCount: pausedTaskCount,
            pendingTaskCount: pendingTaskCount,
          ),
        ],
      ),
    );
  }
}
