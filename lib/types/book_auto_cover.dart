import 'package:cloud_firestore/cloud_firestore.dart';

class BookAutoCover {
  final String id;
  final String url;
  final DateTime updatedAt;

  BookAutoCover({
    this.id,
    this.url,
    this.updatedAt,
  });

  factory BookAutoCover.fromJSON(Map<String, dynamic> data) {
    return BookAutoCover(
      id: data['id'] ?? '',
      url: data['url'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
