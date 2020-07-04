import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/firebase.dart' as fb;

class UploadedItem {
  DocumentReference doc;
  Uri imageUrl;
  bool isExpanded;
  fb.UploadTask task;

  UploadedItem({
    this.doc,
    this.imageUrl,
    this.isExpanded = false,
    this.task,
  });
}
