import 'dart:typed_data';

import 'package:artbooking/actions/books.dart';
import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/cloud_functions/illustrations_response.dart';
import 'package:artbooking/types/cloud_functions/upload_cover_response.dart';
import 'package:artbooking/types/custom_upload_task.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime_type/mime_type.dart';

class UploadTaskListNotifier extends StateNotifier<List<CustomUploadTask>> {
  UploadTaskListNotifier(List<CustomUploadTask> state) : super(state);

  /// Return number of tasks which are either in 1st phase
  /// (Firestor doc creation) or in an uploading/paused state.
  /// This property can be used to update the UI (showing a progress bar)
  /// immediately after selecting a file, and not when the file upload starts.
  /// Which is usally several seconds later.
  int get pendingTaskCount => state.where((customTask) {
        final task = customTask.task;
        return task == null ||
            task.snapshot.state == TaskState.running ||
            task.snapshot.state == TaskState.paused;
      }).length;

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
      if (customUploadTask.task?.snapshot.state != TaskState.success) {
        _cleanTask(customUploadTask);
        continue;
      }

      removeDone(customUploadTask);
    }
  }

  void cancel(CustomUploadTask customUploadTask) {
    _cleanTask(customUploadTask);
  }

  void removeDone(CustomUploadTask customUploadTask) {
    remove(customUploadTask);
  }

  /// A "select file/folder" window will appear. User will have to choose a file.
  /// This file will be then read, and uploaded to firebase storage;
  Future<List<FilePickerCross>> pickImage() async {
    final List<FilePickerCross>? pickerResult =
        await FilePickerCross.importMultipleFromStorage(
      type: FileTypeCross.image,
    ).catchError((error) {
      Utilities.logger.i(error);
      return Future.value([FilePickerCross(Uint8List(0))]);
    });

    if (pickerResult == null || pickerResult.isEmpty) {
      return [];
    }

    if (pickerResult.isNotEmpty && pickerResult.first.length == 0) {
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

  /// Receive a single file
  /// and try to upload it as the new illustration's version.
  Future<FilePickerCross?> handleDropForNewVersion(
    FilePickerCross file,
    Illustration illustration,
  ) async {
    if (file.path == null || !_checkSize(file)) {
      return null;
    }

    _createNewIllustrationVersion(file, illustration);
    return file;
  }

  /// A "select file/folder" window will appear. User will have to choose a file.
  /// This file will be used as the new version for the existing illustration;
  Future<FilePickerCross?> pickImageForNewVersion(
    Illustration illustration,
  ) async {
    FilePickerCross? pickerResult;

    try {
      pickerResult = await FilePickerCross.importFromStorage(
        type: FileTypeCross.image,
      );
    } on Exception catch (_) {}

    if (pickerResult == null ||
        pickerResult.path == null ||
        !_checkSize(pickerResult)) {
      return null;
    }

    _createNewIllustrationVersion(pickerResult, illustration);
    return pickerResult;
  }

  /// Receive a list of files and try to upload images and create illustrations.
  Future<List<FilePickerCross>> handleDropFiles(
    List<FilePickerCross> files,
  ) async {
    final List<FilePickerCross> filteredFiles = files
        .where(_checkSize)
        .where((FilePickerCross file) => file.path != null)
        .toList();

    for (FilePickerCross file in filteredFiles) {
      _uploadIllustration(file);
    }

    return filteredFiles;
  }

  /// Receive a list of files and try to upload images and create illustrations.
  Future<List<FilePickerCross>> handleDropFilesToBook({
    required List<FilePickerCross> files,
    required String bookId,
  }) async {
    final List<FilePickerCross> filteredFiles = files
        .where(_checkSize)
        .where((FilePickerCross file) => file.path != null)
        .toList();

    await _uploadIllustrationToBook(bookId: bookId, files: filteredFiles);
    return filteredFiles;
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

    await _uploadIllustrationToBook(bookId: bookId, files: passedFiles);

    return passedFiles;
  }

  /// Select an image file to upload as this book's cover,
  Future<UploadCoverResponse> pickImageAndSetAsBookCover({
    required String bookId,
  }) async {
    try {
      FilePickerCross pickerResult = await FilePickerCross.importFromStorage(
        type: FileTypeCross.image,
      );

      if (!_checkSize(pickerResult)) {
        return UploadCoverResponse(
          errorMessage: "book_set_cover_error_size_limit".tr(),
          file: pickerResult,
          success: false,
        );
      }

      final HttpsCallableResult response =
          await Utilities.cloud.fun("books-setCover").call({
        "book_id": bookId,
        "cover_type": "uploaded_cover",
      });

      if (!response.data["success"]) {
        return UploadCoverResponse(
          errorMessage: "book_set_cover_error_network".tr(),
          file: pickerResult,
          success: false,
        );
      }

      await _uploadBookCover(
        bookId: bookId,
        file: pickerResult,
      );

      return UploadCoverResponse(
        errorMessage: "",
        file: pickerResult,
        success: true,
      );
    } on Exception catch (error) {
      final String errorMessage = "${'book_set_cover_error'.tr()}. "
          "Error: ${error.toString()}";

      return UploadCoverResponse(
        errorMessage: errorMessage,
        success: false,
      );
    }
  }

  /// Upload a file to Firebase Storage to use as a book's cover.
  Future<CustomUploadTask> _uploadBookCover({
    required String bookId,
    required FilePickerCross file,
  }) async {
    final String fileName =
        file.fileName ?? "${"unknown".tr()}-${DateTime.now()}";

    final customUploadTask = CustomUploadTask(
      name: fileName,
    );

    add(customUploadTask);

    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      return customUploadTask;
    }

    final lastIndexDot = fileName.lastIndexOf(".") + 1;
    final String extension = fileName.substring(lastIndexDot);

    final String cloudStorageFilePath =
        "users/$userId/books/$bookId/cover/original.$extension";

    final storage = FirebaseStorage.instance;
    final UploadTask uploadTask = storage.ref(cloudStorageFilePath).putData(
        file.toUint8List(),
        SettableMetadata(
          customMetadata: {
            "book_id": bookId,
            "extension": extension,
            "file_type": "book_cover",
            "user_id": userId,
            "target": "book",
            "visibility": "public",
          },
          contentType: mimeFromExtension(
            extension,
          ),
        ));

    customUploadTask.task = uploadTask;

    final List<CustomUploadTask> filteredState =
        state.where((CustomUploadTask x) {
      return x.illustrationId != customUploadTask.illustrationId;
    }).toList();

    state = [
      ...filteredState,
      customUploadTask,
    ];

    try {
      await uploadTask;
    } on FirebaseException catch (error) {
      Utilities.logger.e(error);
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      state = [...state];
      return customUploadTask;
    }
  }

  /// Upload a file creating a Firestore document and adding a new file to
  /// Firebase Cloud Storage. Then add this new created illustration to
  /// an existing book.
  Future<void> _uploadIllustrationToBook({
    required List<FilePickerCross> files,
    required String bookId,
  }) async {
    final List<Future<CustomUploadTask>> futureUploads = [];

    for (FilePickerCross passedFile in files) {
      futureUploads.add(_uploadIllustration(passedFile));
    }

    final List<CustomUploadTask> tasks = await Future.wait(futureUploads);
    final List<String> illustrationIds = [];

    for (final CustomUploadTask customUploadTask in tasks) {
      final String illustrationId = customUploadTask.illustrationId ?? "";

      if (illustrationId.isNotEmpty) {
        illustrationIds.add(illustrationId);
      }
    }

    final IllustrationsResponse response = await BooksActions.addIllustrations(
      bookId: bookId,
      illustrationIds: illustrationIds,
    );

    if (response.hasErrors) {
      Utilities.logger.e(
        "There was an error while adding illustrations $illustrationIds.",
      );
    }
  }

  /// Return true if the size is below 25Mo. Return false otherwise.
  bool _checkSize(FilePickerCross file) {
    if (file.length > 25 * 1024 * 1024) {
      return false;
    }

    return true;
  }

  Future<CustomUploadTask> _createNewIllustrationVersion(
    FilePickerCross file,
    Illustration illustration,
  ) async {
    final customUploadTask = CustomUploadTask(
      illustrationId: illustration.id,
      name: illustration.name,
    );

    add(customUploadTask);

    return await _startStorageUpload(
      file: file,
      fileName: illustration.name,
      illustrationId: illustration.id,
      customUploadTask: customUploadTask,
    );
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
      _cleanTask(customUploadTask);
      return customUploadTask;
    }

    customUploadTask.illustrationId = illustrationId;

    return await _startStorageUpload(
      file: file,
      fileName: fileName,
      illustrationId: illustrationId,
      customUploadTask: customUploadTask,
    );
  }

  Future<String> _createFirestoreDocument(String fileName) async {
    try {
      final HttpsCallableResult responseResult =
          await Utilities.cloud.illustrations("createOne").call({
        "name": fileName,
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
    required String illustrationId,
    required CustomUploadTask customUploadTask,
  }) async {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    if (userId.isEmpty) {
      return customUploadTask;
    }

    String extension = file.fileExtension;

    if (extension.isEmpty) {
      final int lastIndexDot = fileName.lastIndexOf(".") + 1;
      extension = fileName.substring(lastIndexDot);
    }

    final String cloudStorageFilePath =
        "users/$userId/illustrations/$illustrationId/original.$extension";

    final FirebaseStorage storage = FirebaseStorage.instance;
    final UploadTask uploadTask = storage.ref(cloudStorageFilePath).putData(
        file.toUint8List(),
        SettableMetadata(
          customMetadata: {
            "extension": extension,
            "firestore_id": illustrationId,
            "file_type": "illustration",
            "user_id": userId,
            "visibility": "public",
          },
          contentType: mimeFromExtension(
            extension,
          ),
        ));

    customUploadTask.task = uploadTask;

    final List<CustomUploadTask> filteredState = state.where((customTask) {
      return customTask.illustrationId != customUploadTask.illustrationId;
    }).toList();

    state = [
      ...filteredState,
      customUploadTask,
    ];

    try {
      await uploadTask;
    } on FirebaseException catch (error) {
      Utilities.logger.e(error);
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      state = [...state];
      return customUploadTask;
    }
  }

  /// Remove the target task from state,
  /// Cancel upload (if it can), delete corresponding Firestore document,
  /// and Firebase storage file (if it has been created).
  void _cleanTask(CustomUploadTask customUploadTask) {
    remove(customUploadTask);
    _deleteFirestoreDocument(customUploadTask);
    customUploadTask.task?.cancel();
  }

  /// Delete the Firestore document created
  /// if the task is running or paused and was uploading the file to storage.
  Future _deleteFirestoreDocument(CustomUploadTask customUploadTask) async {
    final String illustrationId = customUploadTask.illustrationId ?? '';

    if (illustrationId.isEmpty) {
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
