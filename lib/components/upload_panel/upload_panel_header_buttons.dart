import 'package:artbooking/components/upload_panel/upload_panel_cancel_button.dart';
import 'package:artbooking/components/upload_panel/upload_panel_pause_button.dart';
import 'package:artbooking/components/upload_panel/upload_panel_resume_button.dart';
import 'package:flutter/material.dart';

class UploadPanelHeaderButtons extends StatelessWidget {
  const UploadPanelHeaderButtons({
    Key? key,
    required this.runningTaskCount,
    required this.pausedTaskCount,
    required this.pendingTaskCount,
  }) : super(key: key);

  /// Current active tasks
  final int runningTaskCount;

  /// Current paused tasks
  final int pausedTaskCount;

  /// Current pending tasks
  final int pendingTaskCount;

  @override
  Widget build(BuildContext context) {
    Widget pauseResumeButton = Container();

    if (pendingTaskCount > 0) {
      final bool allTaskPaused = runningTaskCount == 0;

      if (allTaskPaused) {
        pauseResumeButton = UploadPanelResumeButton(
          hide: pausedTaskCount == 0,
        );
      }

      pauseResumeButton = UploadPanelPauseButton(
        hide: runningTaskCount == 0,
      );
    }

    return Row(
      children: [
        pauseResumeButton,
        UploadPanelCancelButton(
          pendingTaskCount: pendingTaskCount,
        ),
      ],
    );
  }
}
