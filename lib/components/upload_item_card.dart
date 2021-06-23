import 'dart:async';

import 'package:artbooking/components/circle_button.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/custom_upload_task.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class UploadItemCard extends StatefulWidget {
  // final String name;
  // final String percent;
  // final double progress;
  // final UploadTask uploadTask;
  final CustomUploadTask? customUploadTask;
  final Function? onCancel;
  final Function? onDone;

  const UploadItemCard({
    Key? key,
    // @required this.name,
    // @required this.percent,
    // @required this.progress,
    this.customUploadTask,
    this.onCancel,
    this.onDone,
  }) : super(key: key);

  @override
  _UploadItemCardState createState() => _UploadItemCardState();
}

class _UploadItemCardState extends State<UploadItemCard> {
  double _elevation = 0.0;
  bool _isHover = false;

  int _bytesTransferred = 0;
  int _totalBytes = 0;
  // TaskState _uploadState = TaskState.running;

  StreamSubscription<TaskSnapshot>? _taskListener;

  @override
  void initState() {
    super.initState();

    _taskListener = widget.customUploadTask!.task?.snapshotEvents.listen(
      (TaskSnapshot snapshot) {
        _bytesTransferred = snapshot.bytesTransferred;
        _totalBytes = snapshot.totalBytes;
        // _uploadState = snapshot.state;
      },
      onError: (error) {
        appLogger.e(error);
      },
      onDone: () {
        appLogger.d("upload complete");
        _taskListener?.cancel();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      elevation: _elevation,
      color: stateColors.clairPink,
      child: InkWell(
        onTap: () {},
        onHover: (isHover) {
          _isHover = isHover;

          if (isHover) {
            setState(() {
              _elevation = 2.0;
            });
            return;
          }

          setState(() {
            _elevation = 0.0;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    nameAndProgress(),
                    percentage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget nameAndProgress() {
    final customUploadTask = widget.customUploadTask!;

    double progress = _bytesTransferred / _totalBytes;

    if (customUploadTask.task!.snapshot.state == TaskState.success) {
      progress = 1.0;
    } else if (progress.isNaN || progress.isInfinite) {
      progress = 0;
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.8,
            child: Text(
              customUploadTask.name!,
              style: FontsUtils.mainStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 200.0,
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 2.0,
              color: stateColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget percentage() {
    final double progress = _bytesTransferred / _totalBytes;
    double percent = progress * 100;

    if (widget.customUploadTask!.task!.snapshot.state == TaskState.success) {
      percent = 100;
    } else if (percent.isInfinite || percent.isNaN) {
      percent = 0;
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        actionButton(),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Opacity(
            opacity: 0.6,
            child: Text(
              "${percent.round()}%",
              style: FontsUtils.mainStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget actionButton() {
    if (!_isHover) {
      return Container();
    }

    final state = widget.customUploadTask!.task!.snapshot.state;

    if (state == TaskState.running) {
      return CircleButton(
        tooltip: "cancel".tr(),
        radius: 16.0,
        onTap: widget.onCancel as void Function()?,
        icon: Icon(
          UniconsLine.times,
          size: 16.0,
          color: Colors.black87,
        ),
      );
    }

    if (state == TaskState.success) {
      return CircleButton(
        onTap: widget.onDone as void Function()?,
        tooltip: "done".tr(),
        radius: 16.0,
        icon: Icon(
          UniconsLine.check,
          size: 16.0,
          color: Colors.black87,
        ),
      );
    }

    return Container();
  }
}
