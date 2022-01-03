import 'package:firebase_storage/firebase_storage.dart';

/// A class that contains a upload task and additional properties
/// such as a Firestore document.
class CustomUploadTask {
  CustomUploadTask({
    this.illustrationId = '',
    this.name = '',
    this.task,
  });

  /// Firebase storage upload task.
  UploadTask? task;

  /// The illustration being uploaded.
  String name;

  /// The created illustration in Firestore.
  String? illustrationId;
}
