import 'package:artbooking/types/illustration.dart';
import 'package:firebase/firebase.dart' as fb;

class UploadTask {
  Uri imageUrl;
  bool isExpanded;
  fb.UploadTask task;
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
