import 'package:cloud_firestore/cloud_firestore.dart';

class BookCustomCover {
  final String url;
  final DateTime updatedAt;

  BookCustomCover({this.url, this.updatedAt});

  factory BookCustomCover.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return BookCustomCover(
        url: '',
        updatedAt: DateTime.now(),
      );
    }

    return BookCustomCover(
      url: data['url'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
