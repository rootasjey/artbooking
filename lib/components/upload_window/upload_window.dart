import 'package:artbooking/components/upload_window/upload_window_body.dart';
import 'package:artbooking/components/upload_window/upload_window_header.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/custom_upload_task.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supercharged/supercharged.dart';

class UploadWindow extends ConsumerStatefulWidget {
  const UploadWindow({
    Key? key,
  }) : super(key: key);

  @override
  _UploadWindowState createState() => _UploadWindowState();
}

class _UploadWindowState extends ConsumerState<UploadWindow> {
  bool _isExpanded = false;

  double _width = 260.0;
  double _height = 100.0;

  double _initialWidth = 260.0;
  double _initialHeight = 100.0;

  double _maxWidth = 360.0;
  double _maxHeight = 300.0;

  @override
  Widget build(BuildContext context) {
    final bool showUploadWindow = ref.watch(AppState.showUploadWindowProvider);

    if (!showUploadWindow) {
      return Container();
    }

    final List<CustomUploadTask> uploadTaskList = ref.watch(
      AppState.uploadTaskListProvider,
    );

    final taskListNotifier = AppState.uploadTaskListProvider.notifier;
    final int abortedTaskCount = ref.read(taskListNotifier).abortedTaskCount;
    final int successTaskCount = ref.read(taskListNotifier).successTaskCount;
    final int runningTaskCount = ref.read(taskListNotifier).runningTaskCount;
    final int pausedTaskCount = ref.read(taskListNotifier).pausedTaskCount;

    final bool hasUncompletedTasks =
        runningTaskCount > 0 || pausedTaskCount > 0;

    final int percent = ref.watch(AppState.uploadPercentageProvider);

    return Card(
      elevation: 4.0,
      color: Constants.colors.clairPink,
      child: AnimatedContainer(
        width: _width,
        height: _height,
        duration: 150.milliseconds,
        child: InkWell(
          onTap: () {
            if (_isExpanded) {
              setState(() {
                _width = _initialWidth;
                _height = _initialHeight;
                _isExpanded = false;
              });
              return;
            }

            setState(() {
              _width = _maxWidth;
              _height = _maxHeight;
              _isExpanded = true;
            });
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UploadWindowHeader(
                  runningTaskCount: runningTaskCount,
                  successTaskCount: successTaskCount,
                  hasUncompletedTask: hasUncompletedTasks,
                  abortedTaskCount: abortedTaskCount,
                  pausedTaskCount: pausedTaskCount,
                  percent: percent,
                ),
                UploadWindowBody(
                  isExpanded: _isExpanded,
                  uploadTaskList: uploadTaskList,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
