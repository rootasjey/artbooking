import 'package:artbooking/components/upload_panel/upload_panel_body.dart';
import 'package:artbooking/components/upload_panel/upload_panel_header.dart';
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

  ScrollController _scrollController = ScrollController();

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
    final int pendingTaskCount = ref.read(taskListNotifier).pendingTaskCount;

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
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UploadWindowHeader(
                  pendingTaskCount: pendingTaskCount,
                  runningTaskCount: runningTaskCount,
                  successTaskCount: successTaskCount,
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
