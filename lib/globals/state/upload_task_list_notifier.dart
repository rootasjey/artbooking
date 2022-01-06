import 'package:artbooking/actions/books.dart';
import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/custom_upload_task.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime_type/mime_type.dart';

class UploadTaskListNotifier extends StateNotifier<List<CustomUploadTask>> {
  UploadTaskListNotifier(List<CustomUploadTask> state) : super(state);

  int get abortedTaskCount => state.where((uploadTask) {
        return uploadTask.task?.snapshot.state == TaskState.canceled ||
            uploadTask.task?.snapshot.state == TaskState.error;
      }).length;

  int get successTaskCount => state.where((uploadTask) {
        return uploadTask.task?.snapshot.state == TaskState.success;
      }).length;

  int get runningTaskCount => state.where((uploadTask) {
        return uploadTask.task?.snapshot.state == TaskState.running;
      }).length;

  int get pausedTaskCount => state.where((uploadTask) {
        return uploadTask.task?.snapshot.state == TaskState.paused;
      }).length;

  void add(CustomUploadTask customUploadTask) {
    state = [
      ...state,
      customUploadTask,
    ];
  }

  void clear() {
    state = [];
  }

  void pauseAll() {
    for (var customUploadTask in state) {
      customUploadTask.task?.pause();
    }
  }

  void resumeAll() {
    for (var customUploadTask in state) {
      customUploadTask.task?.resume();
    }
  }

  void remove(CustomUploadTask customUploadTask) {
    state = state.where((uploadTask) {
      return uploadTask.illustrationId != customUploadTask.illustrationId;
    }).toList();
  }

  void cancelAll() {
    for (var customUploadTask in state) {
      _cleanFailedTask(customUploadTask);
    }
  }

  void cancel(CustomUploadTask customUploadTask) {
    _cleanFailedTask(customUploadTask);
  }

  void removeDone(CustomUploadTask customUploadTask) {
    remove(customUploadTask);
  }

  /// A "select file/folder" window will appear. User will have to choose a file.
  /// This file will be then read, and uploaded to firebase storage;
  Future<List<FilePickerCross>> pickImage() async {
    List<FilePickerCross>? pickerResult;

    try {
      pickerResult = await FilePickerCross.importMultipleFromStorage(
        type: FileTypeCross.image,
      );
    } on Exception catch (_) {}

    if (pickerResult == null) {
      return [];
    }

    final List<FilePickerCross> passedFiles = pickerResult
        .where(_checkSize)
        .where((file) => file.path != null)
        .toList();

    for (FilePickerCross passedFile in passedFiles) {
      _uploadIllustration(passedFile);
    }

    return passedFiles;
  }

  /// Select an image file to upload to your illustrations collection,
  /// and add this illustration to the specified book (with its id).
  Future<List<FilePickerCross>> pickImageAndAddToBook({
    required String bookId,
  }) async {
    List<FilePickerCross>? pickerResult;

    try {
      pickerResult = await FilePickerCross.importMultipleFromStorage(
        type: FileTypeCross.image,
      );
    } on Exception catch (_) {}

    if (pickerResult == null) {
      return [];
    }

    final List<FilePickerCross> passedFiles =
        pickerResult.where(_checkSize).toList();

    for (FilePickerCross passedFile in passedFiles) {
      _uploadIllustrationToBook(
        file: passedFile,
        bookId: bookId,
      );
    }

    return passedFiles;
  }

  /// Upload a file creating a Firestore document and adding a new file to
  /// Firebase Cloud Storage. Then add this new created illustration to
  /// an existing book.
  Future _uploadIllustrationToBook({
    required FilePickerCross file,
    required String bookId,
  }) async {
    final customUploadTask = await _uploadIllustration(file);
    final String illustrationId = customUploadTask.illustrationId ?? '';

    if (illustrationId.isEmpty) {
      Utilities.logger.e(
        "A custom task upload cannot have an empty [illustrationId] "
        "at this step.",
      );

      return;
    }

    final response = await BooksActions.addIllustrations(
      bookId: bookId,
      illustrationIds: [illustrationId],
    );

    if (response.hasErrors) {
      Utilities.logger.e(
        "There was an error while adding "
        "the illustration $illustrationId.",
      );
    }
  }

  bool _checkSize(FilePickerCross file) {
    if (file.length > 25 * 1024 * 1024) {
      return false;
    }

    return true;
  }

  Future<CustomUploadTask> _uploadIllustration(FilePickerCross file) async {
    final String fileName =
        file.fileName ?? "${"unknown".tr()}-${DateTime.now()}";

    final customUploadTask = CustomUploadTask(
      name: fileName,
    );

    add(customUploadTask);

    final String illustrationId = await _createFirestoreDocument(fileName);

    if (illustrationId.isEmpty) {
      _cleanFailedTask(customUploadTask);
      return customUploadTask;
    }

    customUploadTask.illustrationId = illustrationId;

    return await _startStorageUpload(
      file: file,
      fileName: fileName,
      filePath: file.path ?? '',
      illustrationId: illustrationId,
      customUploadTask: customUploadTask,
    );
  }

  Future<String> _createFirestoreDocument(String fileName) async {
    try {
      final HttpsCallableResult responseResult =
          await Utilities.cloud.illustrations("createOne").call({
        "name": fileName,
        "isUserAuthor": true,
        "visibility": "public",
      });

      final bool success = responseResult.data["success"];

      if (!success) {
        throw "illustration_create_error".tr();
      }

      return responseResult.data["illustration"]?["id"] ?? '';
    } catch (error) {
      Utilities.logger.e(error);
      return '';
    }
  }

  Future<CustomUploadTask> _startStorageUpload({
    required FilePickerCross file,
    required String fileName,
    required String filePath,
    required String illustrationId,
    required CustomUploadTask customUploadTask,
  }) async {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      return customUploadTask;
    }

    final lastIndexDot = fileName.lastIndexOf(".") + 1;
    final String extension = fileName.substring(lastIndexDot);

    final String cloudStorageFilePath =
        "/users/$userId/illustrations/$illustrationId/original.$extension";

    final File uploadFile = File(filePath);
    final storage = FirebaseStorage.instance;

    final UploadTask uploadTask = storage.ref(cloudStorageFilePath).putFile(
        uploadFile,
        SettableMetadata(
          customMetadata: {
            "extension": extension,
            "firestoreId": illustrationId,
            "userId": userId,
            "visibility": "public",
          },
          contentType: mimeFromExtension(
            extension,
          ),
        ));

    customUploadTask.task = uploadTask;
    final filteredState = state.where((customTask) {
      return customTask.illustrationId != customUploadTask.illustrationId;
    });

    state = [
      ...filteredState,
      customUploadTask,
    ];

    try {
      await uploadTask;
      // _incrSuccessTasks(1);
    } on FirebaseException catch (error) {
      Utilities.logger.e(error);
      // _incrAbortedTasks(1);
    } catch (error) {
      Utilities.logger.e(error);
      // _incrAbortedTasks(1);
    } finally {
      state = state;
      return customUploadTask;
    }
  }

  void _cleanFailedTask(CustomUploadTask customUploadTask) {
    remove(customUploadTask);

    final UploadTask? task = customUploadTask.task;

    if (task != null) {
      task.cancel();
      _deleteFirestoreDocument(customUploadTask);
    }
  }

  /// Delete the Firestore document created
  /// if the task is running or paused and was uploading the file to storage.
  Future _deleteFirestoreDocument(CustomUploadTask customUploadTask) async {
    final String illustrationId = customUploadTask.illustrationId ?? '';

    if (illustrationId.isEmpty) {
      return;
    }

    final state = customUploadTask.task!.snapshot.state;
    final unfinished = state == TaskState.running || state == TaskState.paused;

    if (!unfinished) {
      return;
    }

    try {
      final response = await IllustrationsActions.deleteOne(
        illustrationId: illustrationId,
      );

      if (!response.success) {
        throw "illustration_delete_error".tr();
      }
    } catch (error) {
      Utilities.logger.e(error);
    }
  }
}
