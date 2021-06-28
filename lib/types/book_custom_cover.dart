import 'package:artbooking/utils/date_helper.dart';

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
      updatedAt: DateHelper.fromFirestore(data['updatedAt']),
    );
  }
}
