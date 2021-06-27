import 'dart:io';
import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/types/custom_upload_task.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/cloud_helper.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime_type/mime_type.dart';
import 'package:mobx/mobx.dart';

part 'upload_manager.g.dart';

class UploadManager = UploadManagerBase with _$UploadManager;

abstract class UploadManagerBase with Store {
  /// True if there's at least 1 current upload task.
  @observable
  bool showUploadWindow = false;

  /// Upload tasks list.
  @observable
  List<CustomUploadTask> uploadTasksList = [];

  /// List of tasks to delete.
  @observable
  List<CustomUploadTask> toDeleteTasksList = [];

  /// Sum of all bytes transferred among all current uploads.
  @observable
  int bytesTransferred = 0;

  /// Sum of all total bytes to transfer among all current uploads.
  @observable
  int totalBytes = 0;

  /// Total count of added tasks.
  @observable
  int addedTasksCount = 0;

  /// Total count of paused tasks.
  @observable
  int pausedTasksCount = 0;

  /// Total count of uploading tasks.
  @observable
  int runningTasksCount = 0;

  /// Total count of success tasks.
  @observable
  int successTasksCount = 0;

  /// Total count of aborted tasks.
  @observable
  int abortedTasksCount = 0;

  bool get allPaused => pausedTasksCount == addedTasksCount;

  bool get hasUncompletedTasks =>
      (successTasksCount + abortedTasksCount) != addedTasksCount;

  /// A "select file/folder" window will appear. User will have to choose a file.
  /// This file will be then read, and uploaded to firebase storage;
  Future pickImage(BuildContext context) async {
    List<FilePickerCross>? pickerResult;

    try {
      pickerResult = await FilePickerCross.importMultipleFromStorage(
        type: FileTypeCross.image,
      );
    } on Exception catch (_) {}

    if (pickerResult == null) {
      return;
    }

    for (FilePickerCross file in pickerResult) {
      final bool isOk = _checkFile(file);

      if (isOk) {
        _uploadIllustration(file);
      }
    }
  }

  bool _checkFile(FilePickerCross file) {
    if (file.length > 25 * 1024 * 1024) {
      return false;
    }

    return true;
  }

  /// Return transfert percent (number).
  int getPercent() {
    final double ratio = bytesTransferred / totalBytes;
    double ratioNormalize = ratio;

    if (ratioNormalize.isNaN || ratioNormalize.isInfinite) {
      ratioNormalize = 0.0;
    }

    final double percent = ratioNormalize * 100;
    return percent.round();
  }

  /// Return transfert percentage (string).
  String getPercentage() {
    final double ratio = bytesTransferred / totalBytes;
    double ratioNormalize = ratio;

    if (ratioNormalize.isNaN || ratioNormalize.isInfinite) {
      ratioNormalize = 0.0;
    }

    final double percent = ratioNormalize * 100;

    return "${percent.round()}%";
  }

  /// Remove all current tasks whatever state their are.
  void cancelAll() async {
    // Save tasks to cancel running or paused ones later.
    toDeleteTasksList.addAll(uploadTasksList);

    setUploadWindowsVisibility(false);
    uploadTasksList.clear();

    _resetBytesTransferred();
    _resetTotalBytes();

    _setAbortedTasksCount(0);
    _setAddedTasksCount(0);
    _setPausedTasksCount(0);
    _setRunningTasksCount(0);
    _setSuccessTasksCount(0);

    for (var customUploadTask in toDeleteTasksList) {
      if (customUploadTask.task == null) {
        continue;
      }

      customUploadTask.task!.cancel();
      _deleteFirestoreDocIfUnfinished(customUploadTask);
    }
  }

  void pauseAll() {
    for (var customUploadTask in uploadTasksList) {
      customUploadTask.task?.pause();
      _incrPausedTasks(1);
    }
  }

  void resumeAll() {
    for (var customUploadTask in uploadTasksList) {
      customUploadTask.task?.resume();
      _incrRunningTasks(1);
    }
  }

  void _uploadIllustration(FilePickerCross file) async {
    final customUploadTask = CustomUploadTask(
      name: file.fileName ?? "unknown".tr(),
    );

    addCustomUploadTask(customUploadTask);
    _addToTotalBytes(file.length);

    final String? illustrationId = await _createFirestoreDocument(file);
    customUploadTask.illustrationId = illustrationId;

    _startStorageUpload(
      file: file,
      illustrationId: illustrationId,
      customUploadTask: customUploadTask,
    );
  }

  Future<String?> _createFirestoreDocument(FilePickerCross file) async {
    final String? fileName = file.fileName;

    try {
      final HttpsCallableResult responseResult =
          await Cloud.illustrations("createOne").call({
        "name": fileName,
        "isUserAuthor": true,
        "visibility": "public",
      });

      final bool success = responseResult.data["success"];

      if (!success) {
        throw "illustration_create_error".tr();
      }

      final String? documentId = responseResult.data["illustration"]["id"];
      return documentId;
    } catch (error) {
      appLogger.e(error);
      return "";
    }
  }

  Future _deleteFirestoreDocument(
    CustomUploadTask customUploadTaskasync,
  ) async {
    try {
      final response = await IllustrationsActions.deleteOne(
        illustrationId: customUploadTaskasync.illustrationId!,
      );

      if (!response.success) {
        throw "illustration_delete_error".tr();
      }
    } catch (error) {
      appLogger.e(error);
    }
  }

  void _startStorageUpload({
    FilePickerCross? file,
    String? illustrationId,
    CustomUploadTask? customUploadTask,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return;
    }

    final fileName = file!.fileName!;
    final lastIndexDot = fileName.lastIndexOf(".") + 1;
    final String extension = fileName.substring(lastIndexDot);

    final String filePath =
        "/users/$userId/illustrations/$illustrationId/original.$extension";

    final File uploadFile = File(file.path!);

    final storage = FirebaseStorage.instance;

    final UploadTask uploadTask = storage.ref(filePath).putFile(
        uploadFile,
        SettableMetadata(
          customMetadata: {
            "extension": extension,
            "firestoreId": illustrationId!,
            "userId": userId,
            "visibility": "public",
          },
          contentType: mimeFromExtension(
            extension,
          ),
        ));

    _addUploadTask(uploadTask, customUploadTask!);

    try {
      await uploadTask;
      _incrSuccessTasks(1);
    } on FirebaseException catch (error) {
      appLogger.e(error);
      _incrAbortedTasks(1);
    } catch (error) {
      appLogger.e(error);
      _incrAbortedTasks(1);
    }
  }

  /// Add a new upload task to the manager.
  @action
  void addCustomUploadTask(CustomUploadTask customUploadTask) {
    uploadTasksList.add(customUploadTask);
    setUploadWindowsVisibility(true);
    _incrAddedTasks(1);
  }

  @action
  void _addUploadTask(
    UploadTask uploadTask,
    CustomUploadTask customUploadTask,
  ) {
    customUploadTask.task = uploadTask;
    _incrRunningTasks(1);
  }

  /// Remove a completed or an failed upload task from the manager.
  @action
  void removeCustomUploadTask(CustomUploadTask customUploadTask) {
    uploadTasksList.remove(customUploadTask);
    _decrAddedTasks(1);

    if (customUploadTask.task != null) {
      decrementCounter(customUploadTask);

      final snapshot = customUploadTask.task!.snapshot;

      _removeFromTotalBytes(snapshot.totalBytes);
      removeFromBytesTransferred(snapshot.bytesTransferred);

      customUploadTask.task!.cancel();
      _deleteFirestoreDocIfUnfinished(customUploadTask);
    }

    if (uploadTasksList.isEmpty) {
      setUploadWindowsVisibility(false);
    }
  }

  /// Delete the Firestore document created
  /// if the task is running or paused
  /// and was uploading the file to storage.
  void _deleteFirestoreDocIfUnfinished(
    CustomUploadTask customUploadTask,
  ) async {
    final hasCreatedIllustration =
        customUploadTask.illustrationId?.isNotEmpty ?? false;

    if (!hasCreatedIllustration) {
      return;
    }

    final state = customUploadTask.task!.snapshot.state;
    final unfinished = state == TaskState.running || state == TaskState.paused;

    if (!unfinished) {
      return;
    }

    await _deleteFirestoreDocument(customUploadTask);
  }

  /// Add the [amount] to total bytes among all uploads.
  @action
  void _addToTotalBytes(int amount) {
    totalBytes += amount;
  }

  /// Remove the [amount] from total bytes among all uploads.
  @action
  void _removeFromTotalBytes(int amount) {
    totalBytes -= amount;

    if (totalBytes < 0) {
      totalBytes = 0;
    }
  }

  /// Reset total bytes.
  @action
  void _resetTotalBytes() {
    totalBytes = 0;
  }

  /// Reset bytes transferred.
  @action
  void _resetBytesTransferred() {
    bytesTransferred = 0;
  }

  /// Add the [amount] to bytes transferred among all uploads.
  @action
  void addToBytesTransferred(int amount) {
    bytesTransferred += amount;
  }

  /// Remove the [amount] to bytes transferred among all uploads.
  @action
  void removeFromBytesTransferred(int amount) {
    bytesTransferred -= amount;

    if (bytesTransferred < 0) {
      bytesTransferred = 0;
    }
  }

  @action
  void setUploadWindowsVisibility(bool show) {
    showUploadWindow = show;
  }

  @action
  void _incrAddedTasks(int amount) {
    addedTasksCount += amount;
  }

  @action
  void _decrAddedTasks(int amount) {
    addedTasksCount -= amount;

    if (addedTasksCount < 0) {
      appLogger.w(
        "addedTasksCount is above the limit. "
        "Its value is $addedTasksCount whereas the limit is 0.",
      );

      addedTasksCount = 0;
    }
  }

  @action
  void _setAddedTasksCount(int value) {
    addedTasksCount = value;
  }

  @action
  void _setPausedTasksCount(int value) {
    pausedTasksCount = value;
  }

  @action
  void _setRunningTasksCount(int value) {
    runningTasksCount = value;
  }

  @action
  void _setAbortedTasksCount(int value) {
    abortedTasksCount = value;
  }

  @action
  void _setSuccessTasksCount(int value) {
    successTasksCount = value;
  }

  @action
  void _incrPausedTasks(int amount) {
    pausedTasksCount += amount;

    if (pausedTasksCount > addedTasksCount) {
      appLogger.w(
        "pausedTasksCount is above the limit. "
        "Its value is $pausedTasksCount whereas the limit is $addedTasksCount.",
      );

      pausedTasksCount = addedTasksCount;
    }
  }

  @action
  void _decrPausedTasks(int amount) {
    pausedTasksCount -= amount;

    if (pausedTasksCount < 0) {
      appLogger.w(
        "pausedTasksCount is above the limit. "
        "Its value is $pausedTasksCount whereas the limit is 0.",
      );

      pausedTasksCount = 0;
    }
  }

  @action
  void _incrRunningTasks(int amount) {
    runningTasksCount += amount;

    if (runningTasksCount > addedTasksCount) {
      appLogger.w(
        "runningTasksCount is above the limit. "
        "Its value is $runningTasksCount whereas the limit is $addedTasksCount.",
      );

      runningTasksCount = addedTasksCount;
    }
  }

  @action
  void _decrRunningTasks(int amount) {
    runningTasksCount -= amount;

    if (runningTasksCount < 0) {
      appLogger.w(
        "runningTasksCount is above the limit. "
        "Its value is $runningTasksCount whereas the limit is 0.",
      );

      runningTasksCount = 0;
    }
  }

  @action
  void _decrSuccessTasks(int amount) {
    successTasksCount -= amount;

    if (successTasksCount < 0) {
      appLogger.w(
        "successTasksCount is above the limit. "
        "Its value is $successTasksCount whereas the limit is 0.",
      );

      successTasksCount = 0;
    }
  }

  @action
  void _incrSuccessTasks(int amount) {
    successTasksCount += amount;

    if (successTasksCount > addedTasksCount) {
      appLogger.w(
        "successTasksCount is above the limit. "
        "Its value is $successTasksCount whereas the limit is $addedTasksCount.",
      );

      successTasksCount = addedTasksCount;
    }
  }

  @action
  void _decrAbortedTask(int amount) {
    abortedTasksCount -= amount;

    if (abortedTasksCount < 0) {
      appLogger.w(
        "abortedTasksCount is under the limit. "
        "Its value is $abortedTasksCount whereas the limit is 0.",
      );

      abortedTasksCount = 0;
    }
  }

  @action
  void _incrAbortedTasks(int amount) {
    abortedTasksCount += amount;

    if (abortedTasksCount > addedTasksCount) {
      appLogger.w(
        "abortedTasksCount is above the limit. "
        "Its value is $abortedTasksCount whereas the limit is $addedTasksCount.",
      );

      abortedTasksCount = addedTasksCount;
    }
  }

  void decrementCounter(CustomUploadTask customUploadTask) {
    final state = customUploadTask.task!.snapshot.state;

    switch (state) {
      case TaskState.running:
        _decrRunningTasks(1);
        break;
      case TaskState.paused:
        _decrPausedTasks(1);
        break;
      case TaskState.success:
        _decrSuccessTasks(1);
        break;
      case TaskState.canceled:
      case TaskState.error:
        _decrAbortedTask(1);
        break;
      default:
    }
  }
}

final appUploadManager = UploadManager();
