import 'package:artbooking/components/circle_button.dart';
import 'package:artbooking/components/upload_item_card.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/upload_manager.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class UploadWindow extends StatefulWidget {
  const UploadWindow({
    Key key,
  }) : super(key: key);

  @override
  _UploadWindowState createState() => _UploadWindowState();
}

class _UploadWindowState extends State<UploadWindow> {
  bool _isExpanded = false;

  double _width = 260.0;
  double _height = 100.0;

  double _initialWidth = 260.0;
  double _initialHeight = 100.0;

  double _maxWidth = 360.0;
  double _maxHeight = 300.0;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        if (!appUploadManager.showUploadWindow) {
          return Container();
        }

        return Card(
          elevation: 4.0,
          color: stateColors.clairPink,
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
                    header(),
                    body(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getWindowTitle(),
                  style: FontsUtils.mainStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    getWindowSubtitle(),
                    style: FontsUtils.mainStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pauseAndResumeButtons(),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: CircleButton(
              onTap: () {
                appUploadManager.cancelAll();
              },
              tooltip: "cancel".tr(),
              radius: 16.0,
              icon: Icon(
                UniconsLine.times,
                size: 16.0,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (!_isExpanded) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            thickness: 1.5,
            color: Colors.black12,
            height: 20.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: appUploadManager.uploadTasksList.map((uploadTask) {
              return UploadItemCard(
                customUploadTask: uploadTask,
                onCancel: () {
                  appUploadManager.removeCustomUploadTask(uploadTask);
                },
                onDone: () {
                  appUploadManager.removeCustomUploadTask(uploadTask);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String getWindowTitle() {
    if (appUploadManager.runningTasksCount == 0) {
      return "All done.";
    }

    return "illustration_uploading_files".tr(
      args: [appUploadManager.uploadTasksList.length.toString()],
    );
  }

  String getWindowSubtitle() {
    if (appUploadManager.runningTasksCount == 0) {
      return "";
    }

    return appUploadManager.getPercentage();
  }

  Widget pauseButton() {
    if (appUploadManager.runningTasksCount == 0) {
      return Container();
    }

    return CircleButton(
      radius: 16.0,
      tooltip: "pause".tr(),
      icon: Icon(
        UniconsLine.pause,
        size: 16.0,
        color: Colors.black87,
      ),
    );
  }

  Widget pauseAndResumeButtons() {
    if (!appUploadManager.hasUncompletedTasks) {
      return Container();
    }

    if (appUploadManager.allPaused) {
      return resumeButton();
    }

    return pauseButton();
  }

  Widget resumeButton() {
    if (appUploadManager.pausedTasksCount == 0) {
      return Container();
    }

    return CircleButton(
      onTap: () {
        appUploadManager.resumeAll();
      },
      radius: 16.0,
      tooltip: "resume".tr(),
      icon: Icon(
        UniconsLine.play,
        size: 16.0,
        color: Colors.black87,
      ),
    );
  }
}
