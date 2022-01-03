import 'package:artbooking/components/upload_window/cancel_button.dart';
import 'package:artbooking/components/upload_window/pause_button.dart';
import 'package:artbooking/components/upload_window/resume_button.dart';
import 'package:flutter/material.dart';

class HeaderButtons extends StatelessWidget {
  const HeaderButtons({
    Key? key,
    required this.hasUncompletedTask,
    required this.runningTaskCount,
    required this.pausedTaskCount,
  }) : super(key: key);

  final bool hasUncompletedTask;
  final int runningTaskCount;
  final int pausedTaskCount;

  @override
  Widget build(BuildContext context) {
    Widget pauseResumeButton = Container();

    if (hasUncompletedTask) {
      final bool allTaskPaused = runningTaskCount == 0;

      if (allTaskPaused) {
        pauseResumeButton = ResumeButton(
          hide: pausedTaskCount == 0,
        );
      }

      pauseResumeButton = PauseButton(
        hide: runningTaskCount == 0,
      );
    }

    return Row(
      children: [
        pauseResumeButton,
        CancelButton(),
      ],
    );
  }
}
