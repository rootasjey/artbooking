import 'dart:async';

import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/custom_upload_task.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class UploadPanelItemCard extends ConsumerStatefulWidget {
  const UploadPanelItemCard({
    Key? key,
    required this.customUploadTask,
    this.onCancel,
    this.onDone,
    this.onTap,
  }) : super(key: key);

  /// Upload task to follow upload progression.
  final CustomUploadTask customUploadTask;

  /// Callback event fired if the upload is canceled.
  final void Function()? onCancel;

  /// Callback event fired if the upload has completed.
  final void Function()? onDone;

  /// Callback event fired on item tap.
  final void Function()? onTap;

  @override
  _UploadItemCardState createState() => _UploadItemCardState();
}

class _UploadItemCardState extends ConsumerState<UploadPanelItemCard> {
  /// This items card's elevation.
  double _elevation = 0.0;

  /// True if there's a pointer hover this item card.
  bool _isHover = false;

  /// Data transferred in bytes.
  int _bytesTransferred = 0;

  /// Total file's size in bytes.
  int _totalBytes = 0;

  /// Used to follow upload progression.
  StreamSubscription<TaskSnapshot>? _taskListener;

  @override
  void initState() {
    super.initState();

    _taskListener = widget.customUploadTask.task?.snapshotEvents.listen(
      (TaskSnapshot snapshot) {
        _bytesTransferred = snapshot.bytesTransferred;
        _totalBytes = snapshot.totalBytes;

        ref
            .read(AppState.uploadBytesTransferredProvider.notifier)
            .add(_bytesTransferred);
      },
      onError: (error) {
        Utilities.logger.e(error);
      },
      onDone: () {
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
      color: Constants.colors.clairPink,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (isHover) {
          setState(() {
            _isHover = isHover;
            _elevation = isHover ? 2.0 : 0.0;
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
                    percentageAndButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget nameWidget() {
    return Opacity(
      opacity: 0.8,
      child: Text(
        widget.customUploadTask.name,
        style: Utilities.fonts.body(
          fontSize: 18.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget nameAndProgress() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          nameWidget(),
          progressBar(),
        ],
      ),
    );
  }

  Widget progressBar() {
    final customUploadTask = widget.customUploadTask;

    double progress = _bytesTransferred / _totalBytes;

    if (customUploadTask.task == null) {
      progress = 0;
    } else if (customUploadTask.task!.snapshot.state == TaskState.success) {
      progress = 1.0;
    } else if (progress.isNaN || progress.isInfinite) {
      progress = 0;
    }

    if (progress == 1.0) {
      return Container();
    }

    return Container(
      width: 200.0,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 2.0,
        color: Theme.of(context).secondaryHeaderColor,
      ),
    );
  }

  Widget percentage() {
    if (_isHover) {
      return Container();
    }

    final double progress = _bytesTransferred / _totalBytes;
    double percent = progress * 100;

    final customUploadTask = widget.customUploadTask;

    if (customUploadTask.task == null) {
      percent = 0;
    } else if (widget.customUploadTask.task!.snapshot.state ==
        TaskState.success) {
      percent = 100;
    } else if (percent.isInfinite || percent.isNaN) {
      percent = 0;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Opacity(
        opacity: 0.6,
        child: Text(
          "${percent.round()}%",
          style: Utilities.fonts.body(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget percentageAndButton() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        actionButton(),
        percentage(),
      ],
    );
  }

  Widget actionButton() {
    if (!_isHover) {
      return Container();
    }

    final uploadTask = widget.customUploadTask.task;
    final bool isDone = uploadTask?.snapshot.state == TaskState.success;

    if (!isDone) {
      return CircleButton(
        tooltip: "cancel".tr(),
        radius: 16.0,
        onTap: widget.onCancel,
        icon: Icon(
          UniconsLine.times,
          size: 16.0,
          color: Colors.black87,
        ),
      );
    }

    return CircleButton(
      onTap: widget.onDone,
      tooltip: "done".tr(),
      radius: 16.0,
      icon: Icon(
        UniconsLine.check,
        size: 16.0,
        color: Colors.black87,
      ),
    );
  }
}
