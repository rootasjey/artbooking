import 'dart:io';
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

  bool get hasUncompletedTasks => (runningTasksCount + pausedTasksCount) > 0;

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

  /// Return transfert percentage.
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
  void cancelAll() {
    for (var customUploadTask in uploadTasksList) {
      removeCustomUploadTask(customUploadTask);
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
      name: file.fileName,
    );

    addCustomUploadTask(customUploadTask);

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
      appLogger.d("done uploading $fileName");
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
    // addToTotalBytes(customUploadTask.snapshot.totalBytes);
  }

  @action
  void _addUploadTask(
      UploadTask uploadTask, CustomUploadTask customUploadTask) {
    customUploadTask.task = uploadTask;
    _addToTotalBytes(uploadTask.snapshot.totalBytes);
    _incrRunningTasks(1);
  }

  /// Remove a completed or an failed upload task from the manager.
  @action
  void removeCustomUploadTask(CustomUploadTask customUploadTask) {
    _decrAddedTasks(1);

    if (customUploadTask.task != null) {
      decrementCounter(customUploadTask);

      _removeFromTotalBytes(customUploadTask.task!.snapshot.totalBytes);
      customUploadTask.task!.cancel();
    }

    uploadTasksList.remove(customUploadTask);

    if (uploadTasksList.isEmpty) {
      setUploadWindowsVisibility(false);
    }
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
  }

  /// Add the [amount] to bytes transferred among all uploads.
  @action
  void addToBytesTransferred(int amount) {
    bytesTransferred += amount;
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
    if (addedTasksCount < 1) {
      return;
    }

    addedTasksCount -= amount;
  }

  @action
  void _incrPausedTasks(int amount) {
    if (pausedTasksCount >= addedTasksCount) {
      return;
    }

    pausedTasksCount += amount;
  }

  @action
  void _decrPausedTasks(int amount) {
    if (pausedTasksCount < 1) {
      return;
    }

    pausedTasksCount -= amount;
  }

  @action
  void _incrRunningTasks(int amount) {
    if (runningTasksCount >= addedTasksCount) {
      return;
    }

    runningTasksCount += amount;
  }

  @action
  void _decrRunningTasks(int amount) {
    if (runningTasksCount < 1) {
      return;
    }

    runningTasksCount -= amount;
  }

  @action
  void _decrSuccessTasks(int amount) {
    if (successTasksCount < 1) {
      return;
    }

    successTasksCount -= amount;
  }

  @action
  void _incrSuccessTasks(int amount) {
    if (successTasksCount >= addedTasksCount) {
      return;
    }

    successTasksCount += amount;
  }

  @action
  void _decrAbortedTask(int amount) {
    if (abortedTasksCount < 1) {
      return;
    }

    abortedTasksCount -= amount;
  }

  @action
  void _incrAbortedTasks(int amount) {
    if (abortedTasksCount >= addedTasksCount) {
      return;
    }

    abortedTasksCount += amount;
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
