import 'package:artbooking/types/illustration/illustration.dart';

class UploadTask {
  Uri imageUrl;
  bool isExpanded;
  // fb.UploadTask task;
  Object task;
  String filename;
  Illustration illustration;

  UploadTask({
    this.illustration,
    this.filename = '',
    this.imageUrl,
    this.isExpanded = false,
    this.task,
  });
}
