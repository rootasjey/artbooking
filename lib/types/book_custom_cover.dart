import 'package:artbooking/globals/utilities.dart';

class BookCustomCover {
  final String url;
  final DateTime? updatedAt;

  BookCustomCover({
    required this.url,
    this.updatedAt,
  });

  factory BookCustomCover.empty() {
    return BookCustomCover(
      url: '',
      updatedAt: DateTime.now(),
    );
  }

  factory BookCustomCover.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return BookCustomCover.empty();
    }

    return BookCustomCover(
      url: data['url'] ?? '',
      updatedAt: Utilities.date.fromFirestore(data['updatedAt']),
    );
  }
}
