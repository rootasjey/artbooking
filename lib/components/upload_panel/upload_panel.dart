import 'package:artbooking/components/upload_panel/upload_panel_body.dart';
import 'package:artbooking/components/upload_panel/upload_panel_header.dart';
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
  /// Grow the upload panel to a maxium size if true.
  /// Otherwise minimize the window.
  bool _expanded = false;

  /// Upload's panel current width.
  double _width = 260.0;

  /// Upload's panel current height.
  double _height = 100.0;

  /// Upload's panel initial width.
  double _initialWidth = 260.0;

  /// Upload's panel initial height.
  double _initialHeight = 100.0;

  /// Upload's panel maximum possible width.
  double _maxWidth = 360.0;

  /// Upload's panel maximum possible height.
  double _maxHeight = 300.0;

  /// Page scroll controller
  ScrollController _pageScrollController = ScrollController();

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

    final Size windowSize = MediaQuery.of(context).size;
    final bool isMobileSize =
        windowSize.width < Utilities.size.mobileWidthTreshold;

    return Card(
      margin: EdgeInsets.zero,
      elevation: isMobileSize ? 0.0 : 4.0,
      color: isMobileSize ? Colors.white : Constants.colors.clairPink,
      child: AnimatedContainer(
        width: isMobileSize ? windowSize.width : _width,
        height: _height,
        duration: 150.milliseconds,
        child: InkWell(
          onTap: isMobileSize
              ? () => onShowBottomSheet(uploadTaskList)
              : onToggleExpanded,
          child: SingleChildScrollView(
            controller: _pageScrollController,
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
                if (!isMobileSize)
                  UploadWindowBody(
                    expanded: _expanded,
                    onToggleExpanded: onToggleExpanded,
                    uploadTaskList: uploadTaskList,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onShowBottomSheet(List<CustomUploadTask> uploadTaskList) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    Utilities.ui.showAdaptiveDialog(
      context,
      isMobileSize: isMobileSize,
      builder: (BuildContext context) {
        return Material(
          child: UploadWindowBody(
            expanded: true,
            isMobileSize: isMobileSize,
            onToggleExpanded: onToggleExpanded,
            uploadTaskList: uploadTaskList,
          ),
        );
      },
    );
  }

  void onToggleExpanded() {
    if (_expanded) {
      setState(() {
        _width = _initialWidth;
        _height = _initialHeight;
        _expanded = false;
      });
      return;
    }

    setState(() {
      _width = _maxWidth;
      _height = _maxHeight;
      _expanded = true;
    });
  }
}
